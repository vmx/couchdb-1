% Licensed under the Apache License, Version 2.0 (the "License"); you may not
% use this file except in compliance with the License. You may obtain a copy of
% the License at
%
%   http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
% WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
% License for the specific language governing permissions and limitations under
% the License.

-define(UPR_HEADER_LEN, 24).

-define(UPR_MAGIC_REQUEST, 16#80).
-define(UPR_MAGIC_RESPONSE, 16#81).
-define(UPR_OPCODE_OPEN_CONNECTION, 16#50).
-define(UPR_OPCODE_STREAM_REQUEST, 16#53).
-define(UPR_OPCODE_STREAM_CLOSE, 16#52).
-define(UPR_OPCODE_FAILOVER_LOG_REQUEST, 16#54).
-define(UPR_OPCODE_STREAM_END, 16#55).
-define(UPR_OPCODE_SNAPSHOT_MARKER, 16#56).
-define(UPR_OPCODE_MUTATION, 16#57).
-define(UPR_OPCODE_DELETION, 16#58).
-define(UPR_OPCODE_EXPIRATION, 16#59).
-define(UPR_OPCODE_STATS, 16#10).
-define(UPR_OPCODE_SASL_AUTH, 16#21).
-define(UPR_OPCODE_SELECT_BUCKET, 16#89).
-define(UPR_FLAG_OK, 16#00).
-define(UPR_FLAG_STATE_CHANGED, 16#01).
-define(UPR_FLAG_CONSUMER, 16#00).
-define(UPR_FLAG_PRODUCER, 16#01).
-define(UPR_FLAG_NOFLAG, 16#00).
-define(UPR_FLAG_DISKONLY, 16#02).
-define(UPR_REQUEST_TYPE_MUTATION, 16#03).
-define(UPR_REQUEST_TYPE_DELETION, 16#04).
-define(UPR_STATUS_OK, 16#00).
-define(UPR_STATUS_KEY_NOT_FOUND, 16#01).
-define(UPR_STATUS_KEY_EEXISTS, 16#02).
-define(UPR_STATUS_ROLLBACK, 16#23).
-define(UPR_STATUS_NOT_MY_VBUCKET, 16#07).
-define(UPR_STATUS_ERANGE, 16#22).
-define(UPR_STATUS_SASL_AUTH_FAILED, 16#20).
-define(UPR_SNAPSHOT_TYPE_MEMORY, 16#0).
-define(UPR_SNAPSHOT_TYPE_DISK, 16#1).
% The sizes are in bits
-define(UPR_SIZES_KEY_LENGTH, 16).
-define(UPR_SIZES_PARTITION, 16).
-define(UPR_SIZES_BODY, 32).
-define(UPR_SIZES_OPAQUE, 32).
-define(UPR_SIZES_CAS, 64).
-define(UPR_SIZES_BY_SEQ, 64).
-define(UPR_SIZES_REV_SEQ, 64).
-define(UPR_SIZES_FLAGS, 32).
-define(UPR_SIZES_EXPIRATION, 32).
-define(UPR_SIZES_LOCK, 32).
-define(UPR_SIZES_KEY, 40).
-define(UPR_SIZES_VALUE, 56).
-define(UPR_SIZES_PARTITION_UUID, 64).
-define(UPR_SIZES_RESERVED, 32).
-define(UPR_SIZES_STATUS, 16).
-define(UPR_SIZES_SEQNO, 32).
-define(UPR_SIZES_METADATA_LENGTH, 16).
-define(UPR_SIZES_NRU_LENGTH, 8).
-define(UPR_SIZES_SNAPSHOT_TYPE, 32).

% NOTE vmx 2014-01-16: In ep-engine the maximum size is currently 25
-define(UPR_MAX_FAILOVER_LOG_SIZE, 25).


-record(mutation, {
    seq = 0         :: update_seq(),
    rev_seq = 0     :: non_neg_integer(),
    flags = 0       :: non_neg_integer(),
    expiration = 0  :: non_neg_integer(),
    locktime = 0    :: non_neg_integer(),
    key = <<>>      :: binary(),
    value = <<>>    :: binary(),
    metadata = <<>> :: binary()
}).

-record(upr_doc, {
    id = <<>>       :: binary(),
    body = <<>>     :: binary(),
    % data_type corresponds to content_meta in #doc{} from couch_db.hrl
    data_type = 0   :: 0..255,
    partition = 0   :: partition_id(),
    cas = 0         :: uint64(),
    rev_seq = 0     :: uint64(),
    seq = 0         :: update_seq(),
    flags = 0       :: non_neg_integer(),
    expiration = 0  :: non_neg_integer(),
    deleted = false :: boolean()
}).
