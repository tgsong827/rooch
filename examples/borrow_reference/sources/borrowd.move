module rooch_examples::borrowd {
    use moveos_std::account_storage;
    use moveos_std::storage_context::{Self, StorageContext};
    use moveos_std::tx_context;

    struct BorrowCapability has key, copy, store {}

    struct DataStore has key, copy, store {
        v: u8
    }

    public fun new_borrow_cap() : BorrowCapability {
        BorrowCapability {}
    }

    public fun new_data_store() : DataStore {
        DataStore {
            v: 0
        }
    }

    public fun do_immutable_borrow(
        ctx: &StorageContext,
        _borrow_cap: &BorrowCapability,
    ) {
        let addr = tx_context::sender(storage_context::tx_context(ctx));
        account_storage::global_exists<BorrowCapability>(ctx, addr);
    }

    public fun do_mutable_borrow(
        ctx: &mut StorageContext,
        addr: address,
        data_store: &mut DataStore,
    ) {
        if (account_storage::global_exists<DataStore>(ctx, addr)) {
            data_store.v = data_store.v + 1
        }
    }
}
