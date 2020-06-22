local HIGH_THROUHGPUT = ['gitaly', 'rails', 'workhorse'];
local MEDIUM_THROUGHPUT = ['gke', 'shell', 'sidekiq', 'system'];

local setting(index, env) = if std.member(HIGH_THROUHGPUT, index) then {
  index: {
    lifecycle: {
      name: 'gitlab-infra-ilm-policy',
      rollover_alias: 'pubsub-%s-inf-%s' % [index, env],
    },
    mapping: {
      ignore_malformed: true,
      total_fields: {
        limit: 10000,
      },
    },
  },
  // number_of_shards: 1,
  // number_of_replicas: 1,
}
else if std.member(MEDIUM_THROUGHPUT, index) then {
  index: {
    lifecycle: {
      name: 'gitlab-infra-ilm-policy',
      rollover_alias: 'pubsub-%s-inf-%s' % [index, env],
    },
    mapping: {
      ignore_malformed: true,
    },
  },
  // number_of_shards: 1,
  // number_of_replicas: 1,
} else {
  index: {
    lifecycle: {
      name: 'gitlab-infra-ilm-policy',
      rollover_alias: 'pubsub-%s-inf-%s' % [index, env],
    },
    mapping: {
      ignore_malformed: true,
    },
  },
  // number_of_shards: 1,
  // number_of_replicas: 1,
};

{
  setting:: setting,
}
