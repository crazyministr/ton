/*
    This file is part of TON Blockchain Library.

    TON Blockchain Library is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 2 of the License, or
    (at your option) any later version.

    TON Blockchain Library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with TON Blockchain Library.  If not, see <http://www.gnu.org/licenses/>.

    Copyright 2017-2020 Telegram Systems LLP
*/
#pragma once
#include "validator/validator.h"
#include "adnl/adnl.h"
#include "rldp/rldp.h"
#include "lite-server-rate-limiter.h"

namespace ton::validator {

class ValidatorManagerDiskFactory {
 public:
  static td::actor::ActorOwn<ValidatorManagerInterface> create(PublicKeyHash local_id,
                                                               td::Ref<ValidatorManagerOptions> opts, ShardIdFull shard,
                                                               BlockIdExt shard_top_block_id, std::string db_root,
                                                               bool read_only_ = false);

  static td::actor::ActorOwn<ValidatorManagerInterface> create(
      PublicKeyHash id, td::Ref<ValidatorManagerOptions> opts, ShardIdFull shard, BlockIdExt shard_top_block_id,
      std::string db_root, td::actor::ActorId<keyring::Keyring> keyring, td::actor::ActorId<adnl::Adnl> adnl,
      td::actor::ActorId<rldp::Rldp> rldp, td::actor::ActorId<overlay::Overlays> overlays,
      td::actor::ActorId<ton::liteserver::LiteServerLimiter> lslimiter, bool read_only_ = false);
};

}  // namespace ton::validator
