
<a name="0x3_transaction_fee"></a>

# Module `0x3::transaction_fee`



-  [Resource `TransactionFeePool`](#0x3_transaction_fee_TransactionFeePool)
-  [Function `genesis_init`](#0x3_transaction_fee_genesis_init)
-  [Function `get_gas_factor`](#0x3_transaction_fee_get_gas_factor)
-  [Function `calculate_gas`](#0x3_transaction_fee_calculate_gas)
-  [Function `deposit_fee`](#0x3_transaction_fee_deposit_fee)


<pre><code><b>use</b> <a href="">0x2::account_storage</a>;
<b>use</b> <a href="">0x2::storage_context</a>;
<b>use</b> <a href="coin.md#0x3_coin">0x3::coin</a>;
<b>use</b> <a href="gas_coin.md#0x3_gas_coin">0x3::gas_coin</a>;
</code></pre>



<a name="0x3_transaction_fee_TransactionFeePool"></a>

## Resource `TransactionFeePool`



<pre><code><b>struct</b> <a href="transaction_fee.md#0x3_transaction_fee_TransactionFeePool">TransactionFeePool</a> <b>has</b> store, key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>fee: <a href="coin.md#0x3_coin_Coin">coin::Coin</a>&lt;<a href="gas_coin.md#0x3_gas_coin_GasCoin">gas_coin::GasCoin</a>&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x3_transaction_fee_genesis_init"></a>

## Function `genesis_init`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="transaction_fee.md#0x3_transaction_fee_genesis_init">genesis_init</a>(ctx: &<b>mut</b> <a href="_StorageContext">storage_context::StorageContext</a>, genesis_account: &<a href="">signer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="transaction_fee.md#0x3_transaction_fee_genesis_init">genesis_init</a>(ctx: &<b>mut</b> StorageContext, genesis_account: &<a href="">signer</a>)  {
    <a href="_global_move_to">account_storage::global_move_to</a>(ctx, genesis_account, <a href="transaction_fee.md#0x3_transaction_fee_TransactionFeePool">TransactionFeePool</a>{
        fee: <a href="coin.md#0x3_coin_zero">coin::zero</a>&lt;GasCoin&gt;(),
    })
}
</code></pre>



</details>

<a name="0x3_transaction_fee_get_gas_factor"></a>

## Function `get_gas_factor`

Returns the gas factor of gas.


<pre><code><b>public</b> <b>fun</b> <a href="transaction_fee.md#0x3_transaction_fee_get_gas_factor">get_gas_factor</a>(_ctx: &<a href="_StorageContext">storage_context::StorageContext</a>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="transaction_fee.md#0x3_transaction_fee_get_gas_factor">get_gas_factor</a>(_ctx: &StorageContext): u64 {
    //TODO we should provide a algorithm <b>to</b> cordanate the gas factor based on the network throughput
    <b>return</b> 1
}
</code></pre>



</details>

<a name="0x3_transaction_fee_calculate_gas"></a>

## Function `calculate_gas`



<pre><code><b>public</b> <b>fun</b> <a href="transaction_fee.md#0x3_transaction_fee_calculate_gas">calculate_gas</a>(ctx: &<a href="_StorageContext">storage_context::StorageContext</a>, gas_amount: u64): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="transaction_fee.md#0x3_transaction_fee_calculate_gas">calculate_gas</a>(ctx: &StorageContext, gas_amount: u64): u256{
    (gas_amount <b>as</b> u256) * (<a href="transaction_fee.md#0x3_transaction_fee_get_gas_factor">get_gas_factor</a>(ctx) <b>as</b> u256)
}
</code></pre>



</details>

<a name="0x3_transaction_fee_deposit_fee"></a>

## Function `deposit_fee`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="transaction_fee.md#0x3_transaction_fee_deposit_fee">deposit_fee</a>(ctx: &<b>mut</b> <a href="_StorageContext">storage_context::StorageContext</a>, <a href="gas_coin.md#0x3_gas_coin">gas_coin</a>: <a href="coin.md#0x3_coin_Coin">coin::Coin</a>&lt;<a href="gas_coin.md#0x3_gas_coin_GasCoin">gas_coin::GasCoin</a>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="transaction_fee.md#0x3_transaction_fee_deposit_fee">deposit_fee</a>(ctx: &<b>mut</b> StorageContext, <a href="gas_coin.md#0x3_gas_coin">gas_coin</a>: Coin&lt;GasCoin&gt;) {
    <b>let</b> pool = <a href="_global_borrow_mut">account_storage::global_borrow_mut</a>&lt;<a href="transaction_fee.md#0x3_transaction_fee_TransactionFeePool">TransactionFeePool</a>&gt;(ctx, @rooch_framework);
    <a href="coin.md#0x3_coin_merge">coin::merge</a>(&<b>mut</b> pool.fee, <a href="gas_coin.md#0x3_gas_coin">gas_coin</a>);
}
</code></pre>



</details>
