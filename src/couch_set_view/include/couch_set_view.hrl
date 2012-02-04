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


-define(dbname(SetName, PartId),
      <<SetName/binary, $/, (?l2b(integer_to_list(PartId)))/binary>>).

-define(master_dbname(SetName), <<SetName/binary, "/master">>).

-define(set_num_partitions(SetViewGroup),
        (SetViewGroup#set_view_group.index_header)#set_view_index_header.num_partitions).

-define(set_abitmask(SetViewGroup),
        (SetViewGroup#set_view_group.index_header)#set_view_index_header.abitmask).

-define(set_pbitmask(SetViewGroup),
        (SetViewGroup#set_view_group.index_header)#set_view_index_header.pbitmask).

-define(set_cbitmask(SetViewGroup),
        (SetViewGroup#set_view_group.index_header)#set_view_index_header.cbitmask).

-define(set_seqs(SetViewGroup),
        (SetViewGroup#set_view_group.index_header)#set_view_index_header.seqs).

-define(set_purge_seqs(SetViewGroup),
        (SetViewGroup#set_view_group.index_header)#set_view_index_header.purge_seqs).

-define(set_replicas_on_transfer(SetViewGroup),
        (SetViewGroup#set_view_group.index_header)#set_view_index_header.replicas_on_transfer).


% Used to configure a new set view.
-record(set_view_params, {
    max_partitions = 0,
    % list of initial active partitions (list of integers in the range 0 .. N - 1)
    active_partitions = [],
    % list of initial passive partitions (list of integers in the range 0 .. N - 1)
    passive_partitions = [],
    use_replica_index = false
}).

-define(LATEST_COUCH_SET_VIEW_HEADER_VERSION, 1).

-record(set_view_index_header, {
    version = ?LATEST_COUCH_SET_VIEW_HEADER_VERSION,
    % maximum number of partitions this set view supports
    num_partitions = nil,  % nil means not yet defined
    % active partitions bitmap
    abitmask = 0,
    % passive partitions bitmap
    pbitmask = 0,
    % cleanup partitions bitmap
    cbitmask = 0,
    % update seq numbers from each partition, format: [ {PartitionId, Seq} ]
    seqs = [],
    % purge seq numbers from each partition, format: [ {PartitionId, Seq} ]
    purge_seqs = [],
    id_btree_state = nil,
    view_states = nil,
    has_replica = false,
    replicas_on_transfer = []
}).

-record(set_view_debug_info, {
    original_abitmask,
    original_pbitmask,
    stats
}).

-record(set_view_group_stats, {
    full_updates = 0,
    % # of updates that only finished updating the active partitions
    % (in the phase of updating passive partitions). Normally its value
    % is full_updates - 1.
    partial_updates = 0,
    % # of times the updater was forced to stop (because partition states
    % were updated) while it was still indexing the active partitions.
    stopped_updates = 0,
    compactions = 0,
    % # of interrupted cleanups. Cleanups which were stopped (in order to do
    % higher priority tasks) and left the index in a not yet clean state (but
    % hopefully closer to a clean state).
    cleanup_stops = 0,
    cleanups = 0,
    updater_cleanups = 0,
    update_history = [],
    compaction_history = [],
    cleanup_history = []
}).

-record(set_view_group, {
    sig = nil,
    fd = nil,
    set_name,
    name,
    def_lang,
    design_options = [],
    views,
    lib,
    id_btree = nil,
    query_server = nil,
    waiting_delayed_commit = nil,
    ref_counter = nil,
    index_header = nil,
    db_set = nil,
    type,     % 'main' | 'replica'
    replica_group = nil,
    replica_pid = nil,
    debug_info = #set_view_debug_info{}
}).

-record(set_view, {
    id_num,
    % update seq numbers from each partition, format: [ {PartitionId, Seq} ]
    update_seqs = [],
    % purge seq numbers from each partition, format: [ {PartitionId, Seq} ]
    purge_seqs = [],
    map_names = [],
    def,
    btree = nil,
    reduce_funs = [],
    options = []
}).

-record(set_view_updater_result, {
    group,
    indexing_time,  % seconds (float)
    blocked_time,   % seconds (float)
    state,          % 'updating_active' | 'updating_passive'
    cleanup_kv_count,
    cleanup_time,   % seconds (float)
    inserted_ids,
    deleted_ids,
    inserted_kvs,
    deleted_kvs
}).

-record(set_view_compactor_result, {
    group,
    compact_time,     % seconds (float)
    cleanup_kv_count
}).
