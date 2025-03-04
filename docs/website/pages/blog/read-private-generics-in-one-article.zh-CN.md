---
title: 一文读懂私有泛型函数
description: ""
author: geometryolife
category: Technology
date: 2023/08/23
---

import PostHeader from "/components/blog/postHeader";

<PostHeader />

## 什么是私有泛型函数

私有泛型函数是专门为 Rooch 设计的一种泛型函数，它相比于一般的泛型函数，拥有更严格的约束。

简单来说，私有泛型函数就是拥有 `#[private_generics(T1 [, T2, ... Tn])]` 属性标注的泛型函数。

## 作用

私有泛型函数可以判断泛型类型是否是**调用者所在的模块内**定义的，如果不是则无法使用。对于一般的泛型函数，其他模块定义的类型，通过 `use` 语句导入到当前模块后，仍然能够正常使用。

这意味着，私有泛型函数只适用于**自定义类型**，对于其他模块定义的类型和内置类型均无法使用。

## 例子

### 私有泛型函数不接受内置类型

我们先来看一个不使用私有泛型函数的例子。

```move
module rooch_examples::module1 {
    struct Box<T> has drop {
        v: T
    }

    public fun new_box<T, U>(value: T): Box<T> {
        Box { v: value }
    }

    public fun get_box_value<T>(box: &Box<T>): &T {
        &box.v
    }

    #[test]
    fun test1() {
        let box = new_box<u32, u64>(123);
        assert!(get_box_value(&box) == &123, 1000);
    }
}
```

首先定义一个 `Box<T>` 类型，它是一个泛型结构体，包含了一个类型为 `T` 的字段 `v`。

接着定义两个泛型函数 `new_box` 和 `get_box_value`。函数 `new_box` 用来创建 `Box<T>` 类型的值，函数 `get_box_value` 用来获取 `Box<T>` 类型中的字段值 `v: T`。

> 注意：函数 `new_box` 添加了额外的类型 `U`，实际上函数并没有使用，但为了后续演示私有泛型约束特性，特意添加了 `U` 类型约束。

我们简单地写一个单元测试来验证我们的代码逻辑。我们给 `new_box` 传递一个整数字面量 `123`，并创建一个包装了 `u32` 类型的 `Box<u32>` 类型的值 `box`。在断言表达式中，整数字面量引用 `&123` 会隐式推断为 `&123u32`，`get_box_value` 从 `box` 中获取到 `&123u32`，两者相等，能够顺利通过测试。

运行单元测试：

```shell
$ rooch move test
INCLUDING DEPENDENCY MoveStdlib
INCLUDING DEPENDENCY MoveosStdlib
BUILDING private_generics
Running Move unit tests
[ PASS    ] 0x42::module1::test1
Test result: OK. Total tests: 1; passed: 1; failed: 0
Success
```

接下来我们对泛型函数 `new_box` 进行**私有泛型约束**，在函数的上一行添加 `#[private_generics(T)]` 属性标注，其他地方保持不变：

```shell
#[private_generics(T)]
public fun new_box<T, U>(value: T): Box<T> {
	Box { v: value }
}
```

添加了私有泛型约束后，在调用函数时，类型 `T` 必须在当前模块内定义。显然**内置类型** `u32` 并不是在当前模块定义的，所以此时再运行代码，就会报错，如下：

```shell
$ rooch move test
error: resource type "U32" in function "0x42::module1::new_box" not defined in current module or not allowed
   ┌─ ./sources/module1.move:17:19
   │
17 │         let box = new_box<u32, u64>(123);
   │                   ^^^^^^^^^^^^^^^^^^^^^^


Error: extended checks failed
```

私有泛型并没有约束类型 `U`，所以不会检查类型 `U` 声明的位置是否在当前模块。

### 私有泛型函数使用当前模块定义的自定义类型

基于上面的代码，我们稍作修改：

```move
module rooch_examples::module1 {
    struct Data has drop {
        v: u64
    }

    struct Box<T> has drop {
        v: T
    }

    #[private_generics(T)]
    public fun new_box<T, U>(value: T): Box<T> {
        Box { v: value }
    }

    public fun get_box_value<T>(box: &Box<T>): &T {
        &box.v
    }

    #[test]
    fun test1() {
        let data = Data { v: 123 };
        let box = new_box<Data, u64>(data);
        assert!(get_box_value(&box).v == 123, 1000);
    }
}
```

首先，新增一个自定义类型 `Data`，它是一个常见的结构体，包含一个 `u64` 类型的字段 `v`。

接着修改一下单元测试的函数 `test1`，构造一个 `Data` 类型的数据 `data`，并将私有泛型函数 `new_box` 的泛型类型参数 `u32` 修改为 `Data`，断言中，使用成员运算符 `.` 获取 `data` 内的 `u64` 整数值进行比较。

此时再次运行测试，测试例子又能顺利通过测试了：

```shell
$ rooch move test
INCLUDING DEPENDENCY MoveStdlib
INCLUDING DEPENDENCY MoveosStdlib
BUILDING private_generics
Running Move unit tests
[ PASS    ] 0x42::module1::test1
Test result: OK. Total tests: 1; passed: 1; failed: 0
Success
```

私有泛型函数是在 `module1` 调用的，自定义类型 `Data` 也是在**当前**模块内定义的，因此 `Data` 能通过函数的私有泛型约束。

接下来我们将演示在另一个模块定义一个自定义类型，并通过 `use` 语句将这个自定义类型导入到当前模块，并将其传递给私有泛型函数。猜猜看它是否能同正常使用？

### 私有泛型函数不接受其他模块定义的自定义类型

我们定义一个名为 `module2` 的新模块：

```move
module rooch_examples::module2 {
    struct Data2 has copy, drop {
        v: u64
    }

    public fun new_data(value: u64): Data2 {
        Data2 {
            v: value
        }
    }
}
```

在这个模块里，我们定义一个新的类型 `Data2`，并定义一个创建这个类型的函数 `new_data`。因为在 Move 中，所有的结构体只能在声明它们的模块中构造，字段只能在结构体的模块内部访问，所以要想被外部模块构造，必须要有相应的函数。

接下来，我们继续修改 `module1`：

```move
module rooch_examples::module1 {
    #[test_only]
    use rooch_examples::module2::{new_data, Data2};

    struct Data has drop {
        v: u64
    }

    struct Box<T> has drop {
        v: T
    }

    #[private_generics(T)]
    public fun new_box<T, U>(value: T): Box<T> {
        Box { v: value }
    }

    public fun get_box_value<T>(box: &Box<T>): &T {
        &box.v
    }

    #[test]
    fun test1() {
        let data = Data { v: 123 };
        let box = new_box<Data, u64>(data);
        assert!(get_box_value(&box).v == 123, 1000);
    }

    #[test]
    fun test2() {
        let data2 = new_data(456);
        let box2 = new_box<Data2, Data2>(data2);
        assert!(get_box_value(&box2) == &new_data(456), 2000)
    }
}
```

我们导入 `module2` 定义的类型和函数，然后创建单元测试 `test2`。

测试中我们调用 `new_data` 函数创建 `module2::Data2` 类型的值 `data2`，并在将私有泛型函数的类型参数修改为 `Data2`。

注意，这个时候调用私有泛型函数所传递的类型参数 `Data2` 是在外部模块定义的，显然无法通过私有泛型约束！

此时，运行单元测试：

```shell
$ rooch move test
error: resource type "Data2" in function "0x42::module1::new_box" not defined in current module or not allowed
   ┌─ ./sources/module1.move:32:20
   │
32 │         let box2 = new_box<Data2, u64>(data2);
   │                    ^^^^^^^^^^^^^^^^^^^^^^^^^^


Error: extended checks failed
```

### 模块可以调用其他模块定义的私有泛型函数

接下来，我们再做一个小测试，检查其他模块是否可以调用私有泛型函数。

我们再新建一个模块 `module3`：

```move
module rooch_examples::module3 {
    #[test_only]
    use rooch_examples::module1::{new_box, get_box_value};

    struct Data3 has copy, drop {
        v: u64
    }

    #[test]
    fun test3() {
        let data3 = Data3 { v: 789 };
        let box3 = new_box<Data3, u8>(data3);
        assert!(get_box_value(&box3) == &Data3 { v: 789 }, 3000);
    }
}
```

可以看到，此时 `module3` 导入了 `module1` 定义的私有泛型函数 `new_box` 和获取 `Box<T>` 类型的泛型函数 `get_box_value`。

这个时候我们将 `module1` 中的单元测试 `test2` 注释掉，并重新运行单元测试：

```shell
$ rooch move test
INCLUDING DEPENDENCY MoveStdlib
INCLUDING DEPENDENCY MoveosStdlib
BUILDING private_generics
Running Move unit tests
[ PASS    ] 0x42::module1::test1
[ PASS    ] 0x42::module3::test3
Test result: OK. Total tests: 2; passed: 2; failed: 0
Success
```

## 应用

在 MoveOS 标准库中定义了这样一个函数：

```move
#[private_generics(T)]
/// Move a resource to the account's storage
/// This function equates to `move_to<T>(&signer, resource)` instruction in Move
public fun global_move_to<T: key>(ctx: &mut StorageContext, account: &signer, resource: T){
    let account_address = signer::address_of(account);
    //Auto create the account storage when move resource to the account
    ensure_account_storage(ctx, account_address);
    let account_storage = borrow_account_storage_mut(storage_context::object_storage_mut(ctx), account_address);
    add_resource_to_account_storage(account_storage, resource);
}
```

函数 `global_move_to` 是一个私有泛型函数，被私有泛型约束的类型 `T` 是一种资源类型。调用函数需要传递三个参数（存储上下文，signer，资源）。

首先获取调用当前函数的地址并存到 `account_address` 中，`ensure_account_storage` 确保账户存储存在，接着调用 `borrow_account_storage_mut` 获取账户中的可变借用，最后调用 `add_resource_to_account_storage` 将 `resource` 添加到账户存储中。

像这类私有泛型函数，调用的它的模块必定定义了私有泛型约束的类型，那么接下来看一看在 Rooch Framework 中使用的一个例子：

```move
public(friend) fun init_authentication_keys(ctx: &mut StorageContext, account: &signer) {
  let authentication_keys = AuthenticationKeys {
     authentication_keys: type_table::new(storage_context::tx_context_mut(ctx)),
  };
  account_storage::global_move_to<AuthenticationKeys>(ctx, account, authentication_keys);
}
```

`account_authentication.move` 中的 `init_authentication_keys` 函数用到了 `global_move_to` 私有泛型函数，那么意味者 `AuthenticationKeys` 也必须在当前模块定义。

我们可以在当前模块开头找到 `AuthenticationKeys` 类型的定义：

```move
struct AuthenticationKeys has key{
  authentication_keys: TypeTable,
}
```

## 总结

我们通过了四个小例子，来演示了私有泛型的函数如何定义、如何使用，并带你看了一下在 Rooch Framework 中是如何使用私有泛型函数的，看到这里，相信您已经完全掌握了 Rooch 中私有泛型函数的概念、作用和用法了。
