//# init --addresses test=0x42

//# publish
module test::m {
    use std::string::String;
    use moveos_std::table::{Self, Table};
    use moveos_std::tx_context;
    use moveos_std::storage_context::{Self, StorageContext};
    use moveos_std::object;
    use moveos_std::object_storage;
    use moveos_std::object_id::{ObjectID};
    use moveos_std::account_storage;

    struct KVStore has store, key {
        table: Table<String,vector<u8>>,
    }

    public fun make_kv_store(ctx: &mut StorageContext): KVStore{
        let tx_ctx = storage_context::tx_context_mut(ctx);
        KVStore{
            table: table::new(tx_ctx),
        }
    }

    public fun add(store: &mut KVStore, key: String, value: vector<u8>) {
        table::add(&mut store.table, key, value);
    }

    public fun contains(store: &KVStore, key: String): bool {
        table::contains(&store.table, key)
    }

    public fun borrow(store: &KVStore, key: String): &vector<u8> {
        table::borrow(&store.table, key)
    }

    public fun save_to_object_storage(ctx: &mut StorageContext, kv: KVStore) : ObjectID {
        let tx_ctx = storage_context::tx_context_mut(ctx);
        let sender = tx_context::sender(tx_ctx);
        let object = object::new(tx_ctx, sender, kv);
        let object_id = object::id(&object);
        let object_storage = storage_context::object_storage_mut(ctx);
        object_storage::add(object_storage, object);
        object_id
    }

    public fun borrow_from_object_storage(ctx: &mut StorageContext, object_id: ObjectID): &KVStore {
        let object_storage = storage_context::object_storage(ctx);
        let object = object_storage::borrow(object_storage, object_id);
        object::borrow<KVStore>(object)
    }

    public fun save_to_account_storage(ctx: &mut StorageContext, account: &signer, store: KVStore){
        account_storage::global_move_to(ctx, account, store);
    }

    public fun borrow_from_account_storage(ctx: &StorageContext, account: address) : &KVStore{
        account_storage::global_borrow(ctx, account)
    }

    public fun borrow_mut_from_account_storage(ctx: &mut StorageContext, account: address) : &mut KVStore{
        account_storage::global_borrow_mut(ctx, account)
    }

    public fun move_from_account_storage(ctx: &mut StorageContext, account: address) : KVStore{
        account_storage::global_move_from(ctx, account)
    }

    public fun destroy(kv: KVStore){
        let KVStore{table} = kv;
        table::destroy_empty(table);
    }
}

//# run --signers test
script {
    use std::string;
    use moveos_std::storage_context::{StorageContext};
    use test::m;

    fun main(ctx: &mut StorageContext, sender: signer) {
        let kv = m::make_kv_store(ctx);
        m::add(&mut kv, string::utf8(b"test"), b"value");
        m::save_to_account_storage(ctx, &sender, kv);
    }
}

// check contains
//# run --signers test
script {
    use std::string;
    use moveos_std::storage_context::{Self, StorageContext};
    use test::m;

    fun main(ctx: &mut StorageContext) {
        let sender = storage_context::sender(ctx);
        let kv = m::borrow_from_account_storage(ctx, sender);
        assert!(m::contains(kv, string::utf8(b"test")), 1000);
        let v = m::borrow(kv, string::utf8(b"test"));
        assert!(v == &b"value", 1001);
    }
}

//FIXME destroy no empty table, should failed.
//# run --signers test
script {
    use moveos_std::storage_context::{Self, StorageContext};
    use test::m;

    fun main(ctx: &mut StorageContext) {
        let sender = storage_context::sender(ctx);
        let kv = m::move_from_account_storage(ctx, sender);
        m::destroy(kv);
    }
}