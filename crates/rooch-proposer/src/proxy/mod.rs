// Copyright (c) RoochNetwork
// SPDX-License-Identifier: Apache-2.0

use crate::actor::{
    messages::{TransactionProposeMessage, TransactionProposeResult},
    proposer::ProposerActor,
};
use anyhow::Result;
use coerce::actor::ActorRef;
use moveos_types::transaction::TransactionExecutionInfo;
use rooch_types::transaction::{TransactionSequenceInfo, TypedTransaction};

#[derive(Clone)]
pub struct ProposerProxy {
    pub actor: ActorRef<ProposerActor>,
}

impl ProposerProxy {
    pub fn new(actor: ActorRef<ProposerActor>) -> Self {
        Self { actor }
    }

    pub async fn propose_transaction(
        &self,
        tx: TypedTransaction,
        tx_execution_info: TransactionExecutionInfo,
        tx_sequence_info: TransactionSequenceInfo,
    ) -> Result<TransactionProposeResult> {
        self.actor
            .send(TransactionProposeMessage {
                tx,
                tx_execution_info,
                tx_sequence_info,
            })
            .await?
    }
}
