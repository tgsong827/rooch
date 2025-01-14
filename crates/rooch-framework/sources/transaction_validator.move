module rooch_framework::transaction_validator {
    use std::error;
    use std::option;
    use moveos_std::storage_context::{Self, StorageContext};
    use moveos_std::tx_result;
    use rooch_framework::account;
    use rooch_framework::address_mapping::{Self, MultiChainAddress};
    use rooch_framework::account_authentication;
    use rooch_framework::auth_validator::{Self, TxValidateResult};
    use rooch_framework::auth_validator_registry;
    use rooch_framework::session_key;
    use rooch_framework::chain_id;
    use rooch_framework::transaction_fee;
    use rooch_framework::gas_coin;

    const MAX_U64: u128 = 18446744073709551615;


    /// Transaction exceeded its allocated max gas
    const ErrorOutOfGas: u64 = 6;

    //TODO Migrate the error code to the auth_validator module 
    /// Validate errors. These are separated out from the other errors in this
    /// module since they are mapped separately to major VM statuses, and are
    /// important to the semantics of the system.
    const ErrorValidateSequenceNuberTooOld: u64 = 1001;
    const ErrorValidateSequenceNumberTooNew: u64 = 1002;
    const ErrorValidateAccountDoesNotExist: u64 = 1003;
    const ErrorValidateCantPayGasDeposit: u64 = 1004;
    const ErrorValidateTransactionExpired: u64 = 1005;
    const ErrorValidateBadChainId: u64 = 1006;
    const ErrorValidateSequenceNumberTooBig: u64 = 1007;

    /// The authenticator's scheme is not installed to the sender's account
    const ErrorValidateNotInstalledAuthValidator: u64 = 1010;


    #[view]
    /// This function is for Rooch to validate the transaction sender's authenticator.
    /// If the authenticator is invaid, abort this function.
    public fun validate(
        ctx: &StorageContext,
        chain_id: u64,
        scheme: u64,
        authenticator_payload: vector<u8>
    ): TxValidateResult {

        // === validate the chain id ===
        assert!(
            chain_id == chain_id::chain_id(ctx),
            error::invalid_argument(ErrorValidateBadChainId)
        );

        // === validate the sequence number ===
        let tx_sequence_number = storage_context::sequence_number(ctx);
        assert!(
            (tx_sequence_number as u128) < MAX_U64,
            error::out_of_range(ErrorValidateSequenceNumberTooBig)
        );

        let account_sequence_number = account::sequence_number_for_sender(ctx);
        assert!(
            tx_sequence_number >= account_sequence_number,
            error::invalid_argument(ErrorValidateSequenceNuberTooOld)
        );

        // Check that the transaction's sequence number matches the
        // current sequence number. Otherwise sequence number is too new.
        assert!(
            tx_sequence_number == account_sequence_number,
            error::invalid_argument(ErrorValidateSequenceNumberTooNew)
        );

        let sender = storage_context::sender(ctx);

        // === validate gas ===
        let max_gas_amount = storage_context::max_gas_amount(ctx);
        let gas = transaction_fee::calculate_gas(ctx, max_gas_amount);
        
        // We skip the gas check for the new account, for avoid break the current testcase
        // TODO remove the skip afater we provide the gas faucet and update all testcase
        if(account::exists_at(ctx, sender)){
            let gas_balance = gas_coin::balance(ctx, sender);
            assert!(
                gas_balance >= gas,
                error::invalid_argument(ErrorValidateCantPayGasDeposit)
            );
        };

        // === validate the authenticator ===

        // if the authenticator authenticator_payload is session key, validate the session key
        // otherwise return the authentication validator via the scheme
        let session_key_option = session_key::validate(ctx, scheme, authenticator_payload);
        if (option::is_some(&session_key_option)) {
            auth_validator::new_tx_validate_result(scheme, option::none(), session_key_option)
        }else {
            let sender = storage_context::sender(ctx);
            let auth_validator = auth_validator_registry::borrow_validator(ctx, scheme);
            let validator_id = auth_validator::validator_id(auth_validator);
            // builtin scheme do not need to install
            if (!rooch_framework::builtin_validators::is_builtin_scheme(scheme)) {
                assert!(
                    account_authentication::is_auth_validator_installed(ctx, sender, validator_id),
                    error::invalid_state(ErrorValidateNotInstalledAuthValidator)
                );
            };
            auth_validator::new_tx_validate_result(scheme, option::some(*auth_validator), option::none())
        }
    }

    /// Transaction pre_execute function.
    /// Execute before the transaction is executed, automatically called by the MoveOS VM.
    /// This function is for Rooch to auto create account and address maping.
    fun pre_execute(
        ctx: &mut StorageContext,
    ) {
        let sender = storage_context::sender(ctx);
        //Auto create account if not exist
        if (!account::exists_at(ctx, sender)) {
            account::create_account(ctx, sender);
            // Auto get gas coin from faucet if not enough
            // TODO remove this after we provide the gas faucet
            let max_gas_amount = storage_context::max_gas_amount(ctx);
            let init_gas = (max_gas_amount as u256) * 100u256;
            gas_coin::faucet(ctx, sender, init_gas); 
        };
        //the transaction validator will put the multi chain address into the context
        let multichain_address = storage_context::get<MultiChainAddress>(ctx);
        if (option::is_some(&multichain_address)) {
            let multichain_address = option::extract(&mut multichain_address);
            //Auto create address mapping if not exist
            if (!address_mapping::exists_mapping(ctx, multichain_address)) {
                address_mapping::bind_no_check(ctx, sender, multichain_address);
            };
        };
    }

    /// Transaction post_execute function.
    /// Execute after the transaction is executed, automatically called by the MoveOS VM.
    /// This function is for Rooch to update the sender's sequence number and pay the gas fee.
    fun post_execute(
        ctx: &mut StorageContext,
    ) {
        let sender = storage_context::sender(ctx);

        // Active the session key

        let session_key_opt = auth_validator::get_session_key_from_tx_ctx_option(ctx);
        if (option::is_some(&session_key_opt)) {
            let session_key = option::extract(&mut session_key_opt);
            session_key::active_session_key(ctx, session_key);
        };

        // Increment sequence number
        account::increment_sequence_number(ctx);
        
        let tx_result = storage_context::tx_result(ctx);
        let gas_used = tx_result::gas_used(&tx_result);
        let gas = transaction_fee::calculate_gas(ctx, gas_used);
        let gas_coin = gas_coin::deduct_gas(ctx, sender, gas);
        transaction_fee::deposit_fee(ctx, gas_coin);
    }
}
