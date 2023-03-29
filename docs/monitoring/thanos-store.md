# Thanos Store

Thanos Store provides a caching server for TSDB data stored in object storage (GCS).
The list of stores can be found at <https://thanos.gitlab.net/stores>.  The announced labels help Thanos Query decide where to fan out queries.
If the announced labels for any store appears to be an empty list, the pod may need to be restarted.

Docs: <https://thanos.io/tip/components/store.md/>
