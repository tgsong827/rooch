// Copyright (c) The Starcoin Core Contributors
// SPDX-License-Identifier: Apache-2.0
pub const MUL: u64 = 1;

macro_rules! expand_get_impl_for_native_gas_params {
    ($params: ident $(.$field: ident)+, $map: ident, $prefix: literal, optional $key: literal) => {
        if let Some(val) = $map.get(&format!("{}.{}", $prefix, $key)) {
            $params $(.$field)+ = (*val).into();
        }
    };
    ($params: ident $(.$field: ident)+, $map: ident, $prefix: literal, $key: literal) => {
        $params $(.$field)+ = $map.get(&format!("{}.{}", $prefix, $key)).cloned()?.into();
    };
}

macro_rules! expand_get_for_native_gas_params {
    (test_only $(.$field: ident)+, $(optional $($dummy: ident)?)? $key: literal, $initial_val: expr, $param_ty: ty, $package_name: literal, $params: ident, $gas_schedule: ident) => {
        // TODO(Gas): this is a hack to work-around issue
        // https://github.com/rust-lang/rust/issues/15701
        {
            #[cfg(feature = "testing")]
            fn assign(params: &mut $param_ty, gas_schedule: &std::collections::BTreeMap<String, u64>) -> Option<()> {
                $crate::natives::gas_parameter::expand_get_impl_for_native_gas_params!(params $(.$field)+, gas_schedule, $package_name, $(optional $($dummy)?)? $key);
                Some(())
            }

            #[cfg(not(feature = "testing"))]
            fn assign(_params: &mut $param_ty, _gas_schedule: &std::collections::BTreeMap<String, u64>) -> Option<()> {
                Some(())
            }

            assign(&mut $params, &$gas_schedule)?;
        }
    };
    ($(.$field: ident)+, $(optional $($dummy: ident)?)? $key: literal, $initial_val: expr, $param_ty: ty, $package_name: literal, $params: ident, $gas_schedule: ident) => {
        $crate::natives::gas_parameter::native::expand_get_impl_for_native_gas_params!($params $(.$field)+, $gas_schedule, $package_name, $(optional $($dummy)?)? $key);
    }
}

macro_rules! expand_set_for_native_gas_params {
    (test_only $(.$field: ident)+, $(optional)? $key: literal, $initial_val: expr, $param_ty: ty, $package_name: literal, $params: ident) => {
        {
            #[cfg(feature = "testing")]
            fn assign(params: &mut $param_ty)  {
                params $(.$field)+ = $initial_val.into();
            }

            #[cfg(not(feature = "testing"))]
            fn assign(_params: &mut $param_ty) {
            }

            assign(&mut $params);
        }
    };
    ($(.$field: ident)+, $(optional)? $key: literal, $initial_val: expr, $param_ty: ty, $package_name: literal, $params: ident) => {
        $params $(.$field)+ = $initial_val.into()
    };
}

macro_rules! expand_kv_for_native_gas_params {
    (test_only $(.$field: ident)+, $(optional)? $key: literal, $initial_val: expr, $self: ident) => {
        #[cfg(feature = "testing")]
        ($key, u64::from($self $(.$field)+))
    };
    ($(.$field: ident)+, $(optional)? $key: literal, $initial_val: expr, $self: ident) => {
        ($key, u64::from($self $(.$field)+))
    }
}

#[cfg(test)]
macro_rules! extract_key_for_native_gas_params {
    (test_only $(.$field: ident)+, $(optional)? $key: literal, $initial_val: expr) => {
        #[cfg(feature = "testing")]
        $key
    };
    ($(.$field: ident)+, $(optional)? $key: literal, $initial_val: expr) => {
        $key
    };
}

#[cfg(test)]
macro_rules! extract_path_for_native_gas_params {
    (test_only $(.$field: ident)+, $(optional)? $key: literal, $initial_val: expr) => {
        #[cfg(feature = "testing")]
        stringify!($($field).*)
    };
    ($(.$field: ident)+, $(optional)? $key: literal, $initial_val: expr) => {
        stringify!($($field).*)
    };
}

macro_rules! define_gas_parameters_for_natives {
    ($param_ty: ty, $package_name: literal, [$([$($t: tt)*]),* $(,)?] $(, allow_unmapped = $allow_unmapped: expr)?) => {
        impl crate::natives::gas_parameter::gas_member::FromOnChainGasSchedule for $param_ty {
            fn from_on_chain_gas_schedule(gas_schedule: &std::collections::BTreeMap<String, u64>) -> Option<Self> {
                let mut params = <$param_ty>::zeros();

                $(
                    crate::natives::gas_parameter::native::expand_get_for_native_gas_params!($($t)*, $param_ty, $package_name, params, gas_schedule);
                )*

                Some(params)
            }
        }

        impl crate::natives::gas_parameter::gas_member::ToOnChainGasSchedule for $param_ty {
            fn to_on_chain_gas_schedule(&self) -> Vec<(String, u64)> {
                [$(crate::natives::gas_parameter::native::expand_kv_for_native_gas_params!($($t)*, self)),*]
                    .into_iter().map(|(key, val)| (format!("{}.{}", $package_name, key), val)).collect()
            }
        }

        impl crate::natives::gas_parameter::gas_member::InitialGasSchedule for $param_ty {
            fn initial() -> Self {
                let mut params = <$param_ty>::zeros();

                $(
                    crate::natives::gas_parameter::native::expand_set_for_native_gas_params!($($t)*, $param_ty, $package_name, params);
                )*

                params
            }
        }

        #[test]
        fn keys_should_be_unique() {
            let mut map = std::collections::BTreeMap::<&str, ()>::new();

            for key in [$(crate::natives::gas_parameter::native::extract_key_for_native_gas_params!($($t)*)),*] {
                if map.insert(key.clone(), ()).is_some() {
                    panic!("duplicated key {}", key);
                }
            }
        }

        #[test]
        fn paths_must_be_unique() {
            let mut map = std::collections::BTreeMap::<&str, ()>::new();

            for path in [$(crate::natives::gas_parameter::native::extract_path_for_native_gas_params!($($t)*)),*] {
                if map.insert(path.clone(), ()).is_some() {
                    panic!("duplicated path {}", path);
                }
            }
        }
    };
}

#[cfg(test)]
pub(crate) use extract_key_for_native_gas_params;
#[cfg(test)]
pub(crate) use extract_path_for_native_gas_params;

pub(crate) use define_gas_parameters_for_natives;
pub(crate) use expand_get_for_native_gas_params;
pub(crate) use expand_get_impl_for_native_gas_params;
pub(crate) use expand_kv_for_native_gas_params;
pub(crate) use expand_set_for_native_gas_params;
