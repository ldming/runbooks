local basic = import 'grafana/basic.libsonnet';
local layout = import 'grafana/layout.libsonnet';

basic.dashboard(
  'OpenAI Cost Tracking',
  tags=[],
)
.addPanels(
  layout.grid([
    basic.statPanel(
      '',
      'Total Tokens Spent',
      color='',
      query='sum(increase(gitlab_cloud_cost_spend_entry_total{env="$environment", vendor="open_ai", unit="tokens"}[$__range]))',
      instant=true,
      colorMode='none',
      unit='locale',
    ),
    basic.statPanel(
      '',
      'Prompt Tokens Spent',
      color='',
      query='sum(increase(gitlab_cloud_cost_spend_entry_total{env="$environment", vendor="open_ai", unit="tokens", item=~".*/prompt"}[$__range]))',
      instant=true,
      colorMode='none',
      unit='locale',
    ),
    basic.statPanel(
      '',
      'Total Completion Tokens Spent',
      color='',
      query='sum(increase(gitlab_cloud_cost_spend_entry_total{env="$environment", vendor="open_ai", unit="tokens", item=~".*/completion"}[$__range]))',
      instant=true,
      colorMode='none',
      unit='locale',
    ),
  ], cols=3, rowHeight=5, startRow=1)
)
.addPanels(
  layout.grid([
    basic.timeseries(
      title='Total Tokens Spent',
      query='sum(increase(gitlab_cloud_cost_spend_entry_total{env="$environment", vendor="open_ai", unit="tokens"}[$__interval]))',
      legendFormat='Amount'
    ),
    basic.timeseries(
      title='Prompt Tokens Spent',
      query='sum(increase(gitlab_cloud_cost_spend_entry_total{env="$environment", vendor="open_ai", unit="tokens", item=~".*/prompt"}[$__interval]))',
      legendFormat='Amount'
    ),
    basic.timeseries(
      title='Completion Tokens Spent',
      query='sum(increase(gitlab_cloud_cost_spend_entry_total{env="$environment", vendor="open_ai", unit="tokens", item=~".*/completion"}[$__interval]))',
      legendFormat='Amount'
    ),
  ], cols=3, rowHeight=10, startRow=2)
)
.addPanels(
  layout.grid([
    basic.timeseries(
      title='Chat Tokens Spent',
      query='sum(increase(gitlab_cloud_cost_spend_entry_total{env="$environment", vendor="open_ai", unit="tokens", item=~"chat/.*"}[$__interval]))',
      legendFormat='Amount'
    ),
    basic.timeseries(
      title='Chat Prompt Tokens Spent',
      query='sum(increase(gitlab_cloud_cost_spend_entry_total{env="$environment", vendor="open_ai", unit="tokens", item="chat/prompt"}[$__interval]))',
      legendFormat='Amount'
    ),
    basic.timeseries(
      title='Chat Completion Tokens Spent',
      query='sum(increase(gitlab_cloud_cost_spend_entry_total{env="$environment", vendor="open_ai", unit="tokens", item="chat/completion"}[$__interval]))',
      legendFormat='Amount'
    ),
  ], cols=3, rowHeight=10, startRow=2)
)
.addPanels(
  layout.grid([
    basic.timeseries(
      title='Completions Tokens Spent',
      query='sum(increase(gitlab_cloud_cost_spend_entry_total{env="$environment", vendor="open_ai", unit="tokens", item=~"completions/.*"}[$__interval]))',
      legendFormat='Amount'
    ),
    basic.timeseries(
      title='Completions Prompt Tokens Spent',
      query='sum(increase(gitlab_cloud_cost_spend_entry_total{env="$environment", vendor="open_ai", unit="tokens", item="completions/prompt"}[$__interval]))',
      legendFormat='Amount'
    ),
    basic.timeseries(
      title='Completions Completion Tokens Spent',
      query='sum(increase(gitlab_cloud_cost_spend_entry_total{env="$environment", vendor="open_ai", unit="tokens", item="completions/completion"}[$__interval]))',
      legendFormat='Amount'
    ),
  ], cols=3, rowHeight=10, startRow=2)
)
.addPanels(
  layout.grid([
    basic.timeseries(
      title='Edits Tokens Spent',
      query='sum(increase(gitlab_cloud_cost_spend_entry_total{env="$environment", vendor="open_ai", unit="tokens", item=~"edits/.*"}[$__interval]))',
      legendFormat='Amount'
    ),
    basic.timeseries(
      title='Edits Prompt Tokens Spent',
      query='sum(increase(gitlab_cloud_cost_spend_entry_total{env="$environment", vendor="open_ai", unit="tokens", item="edits/prompt"}[$__interval]))',
      legendFormat='Amount'
    ),
    basic.timeseries(
      title='Edits Completion Tokens Spent',
      query='sum(increase(gitlab_cloud_cost_spend_entry_total{env="$environment", vendor="open_ai", unit="tokens", item="edits/completion"}[$__interval]))',
      legendFormat='Amount'
    ),
  ], cols=3, rowHeight=10, startRow=2)
)
.addPanels(
  layout.grid([
    basic.timeseries(
      title='Embeddings Tokens Spent',
      query='sum(increase(gitlab_cloud_cost_spend_entry_total{env="$environment", vendor="open_ai", unit="tokens", item=~"embeddings/.*"}[$__interval]))',
      legendFormat='Amount'
    ),
    basic.timeseries(
      title='Embeddings Prompt Tokens Spent',
      query='sum(increase(gitlab_cloud_cost_spend_entry_total{env="$environment", vendor="open_ai", unit="tokens", item="embeddings/prompt"}[$__interval]))',
      legendFormat='Amount'
    ),
    basic.timeseries(
      title='Embeddings Completion Tokens Spent',
      query='sum(increase(gitlab_cloud_cost_spend_entry_total{env="$environment", vendor="open_ai", unit="tokens", item="embeddings/completion"}[$__interval]))',
      legendFormat='Amount'
    ),
  ], cols=3, rowHeight=10, startRow=2)
)
