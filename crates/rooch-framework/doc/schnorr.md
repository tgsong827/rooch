
<a name="0x3_schnorr"></a>

# Module `0x3::schnorr`



-  [Constants](#@Constants_0)
-  [Function `scheme_length`](#0x3_schnorr_scheme_length)
-  [Function `public_key_length`](#0x3_schnorr_public_key_length)
-  [Function `signature_length`](#0x3_schnorr_signature_length)
-  [Function `sha256`](#0x3_schnorr_sha256)
-  [Function `get_public_key_from_authenticator_payload`](#0x3_schnorr_get_public_key_from_authenticator_payload)
-  [Function `get_signature_from_authenticator_payload`](#0x3_schnorr_get_signature_from_authenticator_payload)
-  [Function `verify`](#0x3_schnorr_verify)


<pre><code></code></pre>



<a name="@Constants_0"></a>

## Constants


<a name="0x3_schnorr_ErrorInvalidPubKey"></a>

Error if the public key is invalid.


<pre><code><b>const</b> <a href="schnorr.md#0x3_schnorr_ErrorInvalidPubKey">ErrorInvalidPubKey</a>: u64 = 1;
</code></pre>



<a name="0x3_schnorr_ErrorInvalidSignature"></a>

Error if the signature is invalid.


<pre><code><b>const</b> <a href="schnorr.md#0x3_schnorr_ErrorInvalidSignature">ErrorInvalidSignature</a>: u64 = 0;
</code></pre>



<a name="0x3_schnorr_KECCAK256"></a>

Hash function name that are valid for verify.


<pre><code><b>const</b> <a href="schnorr.md#0x3_schnorr_KECCAK256">KECCAK256</a>: u8 = 0;
</code></pre>



<a name="0x3_schnorr_SHA256"></a>



<pre><code><b>const</b> <a href="schnorr.md#0x3_schnorr_SHA256">SHA256</a>: u8 = 1;
</code></pre>



<a name="0x3_schnorr_SCHNORR_PUBKEY_LENGTH"></a>



<pre><code><b>const</b> <a href="schnorr.md#0x3_schnorr_SCHNORR_PUBKEY_LENGTH">SCHNORR_PUBKEY_LENGTH</a>: u64 = 32;
</code></pre>



<a name="0x3_schnorr_SCHNORR_SIG_LENGTH"></a>



<pre><code><b>const</b> <a href="schnorr.md#0x3_schnorr_SCHNORR_SIG_LENGTH">SCHNORR_SIG_LENGTH</a>: u64 = 64;
</code></pre>



<a name="0x3_schnorr_SCHNORR_TO_SCHEME_NOSTR_LENGTH"></a>

constant codes


<pre><code><b>const</b> <a href="schnorr.md#0x3_schnorr_SCHNORR_TO_SCHEME_NOSTR_LENGTH">SCHNORR_TO_SCHEME_NOSTR_LENGTH</a>: u64 = 1;
</code></pre>



<a name="0x3_schnorr_scheme_length"></a>

## Function `scheme_length`

built-in functions


<pre><code><b>public</b> <b>fun</b> <a href="schnorr.md#0x3_schnorr_scheme_length">scheme_length</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="schnorr.md#0x3_schnorr_scheme_length">scheme_length</a>(): u64 {
    <a href="schnorr.md#0x3_schnorr_SCHNORR_TO_SCHEME_NOSTR_LENGTH">SCHNORR_TO_SCHEME_NOSTR_LENGTH</a>
}
</code></pre>



</details>

<a name="0x3_schnorr_public_key_length"></a>

## Function `public_key_length`



<pre><code><b>public</b> <b>fun</b> <a href="schnorr.md#0x3_schnorr_public_key_length">public_key_length</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="schnorr.md#0x3_schnorr_public_key_length">public_key_length</a>(): u64 {
    <a href="schnorr.md#0x3_schnorr_SCHNORR_PUBKEY_LENGTH">SCHNORR_PUBKEY_LENGTH</a>
}
</code></pre>



</details>

<a name="0x3_schnorr_signature_length"></a>

## Function `signature_length`



<pre><code><b>public</b> <b>fun</b> <a href="schnorr.md#0x3_schnorr_signature_length">signature_length</a>(): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="schnorr.md#0x3_schnorr_signature_length">signature_length</a>(): u64 {
    <a href="schnorr.md#0x3_schnorr_SCHNORR_SIG_LENGTH">SCHNORR_SIG_LENGTH</a>
}
</code></pre>



</details>

<a name="0x3_schnorr_sha256"></a>

## Function `sha256`



<pre><code><b>public</b> <b>fun</b> <a href="schnorr.md#0x3_schnorr_sha256">sha256</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="schnorr.md#0x3_schnorr_sha256">sha256</a>(): u8 {
    <a href="schnorr.md#0x3_schnorr_SHA256">SHA256</a>
}
</code></pre>



</details>

<a name="0x3_schnorr_get_public_key_from_authenticator_payload"></a>

## Function `get_public_key_from_authenticator_payload`



<pre><code><b>public</b> <b>fun</b> <a href="schnorr.md#0x3_schnorr_get_public_key_from_authenticator_payload">get_public_key_from_authenticator_payload</a>(authenticator_payload: &<a href="">vector</a>&lt;u8&gt;): <a href="">vector</a>&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="schnorr.md#0x3_schnorr_get_public_key_from_authenticator_payload">get_public_key_from_authenticator_payload</a>(authenticator_payload: &<a href="">vector</a>&lt;u8&gt;): <a href="">vector</a>&lt;u8&gt; {
    <b>let</b> public_key = <a href="_empty">vector::empty</a>&lt;u8&gt;();
    <b>let</b> i = <a href="schnorr.md#0x3_schnorr_scheme_length">scheme_length</a>() + <a href="schnorr.md#0x3_schnorr_signature_length">signature_length</a>();
    <b>let</b> public_key_position = <a href="schnorr.md#0x3_schnorr_scheme_length">scheme_length</a>() + <a href="schnorr.md#0x3_schnorr_signature_length">signature_length</a>() + <a href="schnorr.md#0x3_schnorr_public_key_length">public_key_length</a>();
    <b>while</b> (i &lt; public_key_position) {
        <b>let</b> value = <a href="_borrow">vector::borrow</a>(authenticator_payload, i);
        <a href="_push_back">vector::push_back</a>(&<b>mut</b> public_key, *value);
        i = i + 1;
    };
    public_key
}
</code></pre>



</details>

<a name="0x3_schnorr_get_signature_from_authenticator_payload"></a>

## Function `get_signature_from_authenticator_payload`



<pre><code><b>public</b> <b>fun</b> <a href="schnorr.md#0x3_schnorr_get_signature_from_authenticator_payload">get_signature_from_authenticator_payload</a>(authenticator_payload: &<a href="">vector</a>&lt;u8&gt;): <a href="">vector</a>&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="schnorr.md#0x3_schnorr_get_signature_from_authenticator_payload">get_signature_from_authenticator_payload</a>(authenticator_payload: &<a href="">vector</a>&lt;u8&gt;): <a href="">vector</a>&lt;u8&gt; {
    <b>let</b> sign = <a href="_empty">vector::empty</a>&lt;u8&gt;();
    <b>let</b> i = <a href="schnorr.md#0x3_schnorr_scheme_length">scheme_length</a>();
    <b>let</b> signature_position = <a href="schnorr.md#0x3_schnorr_signature_length">signature_length</a>() + 1;
    <b>while</b> (i &lt; signature_position) {
        <b>let</b> value = <a href="_borrow">vector::borrow</a>(authenticator_payload, i);
        <a href="_push_back">vector::push_back</a>(&<b>mut</b> sign, *value);
        i = i + 1;
    };
    sign
}
</code></pre>



</details>

<a name="0x3_schnorr_verify"></a>

## Function `verify`

@param signature: A 64-bytes signature that is signed using Schnorr over Secpk256k1 key pairs.
@param public_key: A 32-bytes public key that is used to sign messages.
@param msg: The message that the signature is signed against.
@param hash: The hash function used to hash the message when signing.

If the signature is valid to the pubkey and hashed message, return true. Else false.


<pre><code><b>public</b> <b>fun</b> <a href="schnorr.md#0x3_schnorr_verify">verify</a>(signature: &<a href="">vector</a>&lt;u8&gt;, public_key: &<a href="">vector</a>&lt;u8&gt;, msg: &<a href="">vector</a>&lt;u8&gt;, <a href="">hash</a>: u8): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>native</b> <b>public</b> <b>fun</b> <a href="schnorr.md#0x3_schnorr_verify">verify</a>(
    signature: &<a href="">vector</a>&lt;u8&gt;,
    public_key: &<a href="">vector</a>&lt;u8&gt;,
    msg: &<a href="">vector</a>&lt;u8&gt;,
    <a href="">hash</a>: u8
): bool;
</code></pre>



</details>
