#![cfg_attr(not(feature = "export-abi"), no_main)]
extern crate alloc;

#[global_allocator]
static ALLOC: mini_alloc::MiniAlloc = mini_alloc::MiniAlloc::INIT;

use stylus_sdk::{ alloy_primitives::Address, call::Call, prelude::*};

// Interfaces for the Art contract and the ERC20 contract
sol_interface! {
    interface TargetContract {
        function callBack() external returns(string);
    }
}


#[solidity_storage]
#[entrypoint]
pub struct CallBack;

#[external]
impl CallBack {
    pub fn execute(&mut self, target: Address) -> String {
		let target_contract = TargetContract::new(target);
		let config = Call::new_in(self);
		
        let result = target_contract.call_back(config);
        result.unwrap()
    }
    pub fn check(&self, message: String) -> Result<String, Vec<u8>> {
        Ok(message.into())
    }
}