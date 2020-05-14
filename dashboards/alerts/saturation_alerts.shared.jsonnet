local saturationAlerts = import 'alerts/saturation_alerts.libsonnet';

{
  sat_active_db_connections: saturationAlerts.saturationDashboardForComponent('active_db_connections'),
  sat_cgroup_memory: saturationAlerts.saturationDashboardForComponent('cgroup_memory', 'gitaly'),
  sat_cpu: saturationAlerts.saturationDashboardForComponent('cpu'),
  sat_disk_space: saturationAlerts.saturationDashboardForComponent('disk_space'),
  sat_disk_sus_read_iops: saturationAlerts.saturationDashboardForComponent('disk_sustained_read_iops', 'patroni'),
  sat_disk_sus_read_throughput: saturationAlerts.saturationDashboardForComponent('disk_sustained_read_throughput', 'patroni'),
  sat_disk_sus_write_iops: saturationAlerts.saturationDashboardForComponent('disk_sustained_write_iops', 'patroni'),
  sat_disk_sus_write_throughput: saturationAlerts.saturationDashboardForComponent('disk_sustained_write_throughput', 'patroni'),
  sat_go_memory: saturationAlerts.saturationDashboardForComponent('go_memory'),
  sat_memory: saturationAlerts.saturationDashboardForComponent('memory'),
  sat_open_fds: saturationAlerts.saturationDashboardForComponent('open_fds'),
  sat_pgbouncer_async_pool: saturationAlerts.saturationDashboardForComponent('pgbouncer_async_pool', 'pgbouncer'),
  sat_pgbouncer_single_core: saturationAlerts.saturationDashboardForComponent('pgbouncer_single_core', 'patroni'),
  sat_pgbouncer_sync_pool: saturationAlerts.saturationDashboardForComponent('pgbouncer_sync_pool', 'pgbouncer'),
  sat_private_runners: saturationAlerts.saturationDashboardForComponent('private_runners'),
  sat_redis_clients: saturationAlerts.saturationDashboardForComponent('redis_clients', 'redis'),
  sat_redis_memory: saturationAlerts.saturationDashboardForComponent('redis_memory', 'redis'),
  sat_shared_runners: saturationAlerts.saturationDashboardForComponent('shared_runners'),
  sat_shared_runners_gitlab: saturationAlerts.saturationDashboardForComponent('shared_runners_gitlab'),
  sat_sidekiq_workers: saturationAlerts.saturationDashboardForComponent('sidekiq_workers', 'sidekiq'),
  sat_single_node_cpu: saturationAlerts.saturationDashboardForComponent('single_node_cpu'),
  sat_single_node_puma_workers: saturationAlerts.saturationDashboardForComponent('single_node_puma_workers'),
  sat_single_node_unicorn_workers: saturationAlerts.saturationDashboardForComponent('single_node_unicorn_workers'),
  sat_single_threaded_cpu: saturationAlerts.saturationDashboardForComponent('single_threaded_cpu', 'redis'),
  sat_workers: saturationAlerts.saturationDashboardForComponent('workers'),
}
