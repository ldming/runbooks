{
  "annotations": {
    "list": [
      {
        "builtIn": 1,
        "datasource": "-- Grafana --",
        "enable": true,
        "hide": true,
        "iconColor": "rgba(0, 211, 255, 1)",
        "name": "Annotations & Alerts",
        "type": "dashboard"
      }
    ]
  },
  "description": "Web-site Lighthouse Performance Audits ",
  "editable": true,
  "gnetId": 9510,
  "graphTooltip": 0,
  "id": 1378,
  "iteration": 1596721822575,
  "links": [
    {
      "icon": "external link",
      "tags": [],
      "targetBlank": true,
      "title": "Pagespeed v3 Reference",
      "tooltip": "Opens the pagespeed reference",
      "type": "link",
      "url": "https://developers.google.com/web/tools/lighthouse/v3/scoring"
    }
  ],
  "panels": [
    {
      "collapsed": false,
      "datasource": null,
      "gridPos": {
        "h": 1,
        "w": 24,
        "x": 0,
        "y": 0
      },
      "id": 6,
      "panels": [],
      "repeat": "strategy",
      "scopedVars": {
        "strategy": {
          "selected": false,
          "text": "desktop",
          "value": "desktop"
        }
      },
      "title": "Overview ($strategy)",
      "type": "row"
    },
    {
      "content": "#### Lighthouse scores for $strategy\n* 0 to 49 (slow): Red\n* 50 to 89 (average): Orange\n* 90 to 100 (fast): Green\n",
      "datasource": null,
      "fieldConfig": {
        "defaults": {
          "custom": {}
        },
        "overrides": []
      },
      "gridPos": {
        "h": 4,
        "w": 4,
        "x": 0,
        "y": 1
      },
      "id": 27,
      "links": [],
      "mode": "markdown",
      "scopedVars": {
        "strategy": {
          "selected": false,
          "text": "desktop",
          "value": "desktop"
        }
      },
      "title": "",
      "transparent": true,
      "type": "text"
    },
    {
      "cacheTimeout": null,
      "colorBackground": false,
      "colorPostfix": false,
      "colorPrefix": false,
      "colorValue": true,
      "colors": [
        "#d44a3a",
        "rgba(237, 129, 40, 0.89)",
        "#299c46"
      ],
      "datasource": "Global",
      "description": "Performance Score",
      "fieldConfig": {
        "defaults": {
          "custom": {}
        },
        "overrides": []
      },
      "format": "none",
      "gauge": {
        "maxValue": 100,
        "minValue": 0,
        "show": true,
        "thresholdLabels": false,
        "thresholdMarkers": true
      },
      "gridPos": {
        "h": 4,
        "w": 4,
        "x": 4,
        "y": 1
      },
      "id": 17,
      "interval": null,
      "links": [],
      "mappingType": 1,
      "mappingTypes": [
        {
          "name": "value to text",
          "value": 1
        },
        {
          "name": "range to text",
          "value": 2
        }
      ],
      "maxDataPoints": 100,
      "maxPerRow": 4,
      "nullPointMode": "connected",
      "nullText": null,
      "postfix": "",
      "postfixFontSize": "50%",
      "prefix": "",
      "prefixFontSize": "50%",
      "rangeMaps": [
        {
          "from": "null",
          "text": "N/A",
          "to": "null"
        }
      ],
      "repeatDirection": "h",
      "scopedVars": {
        "strategy": {
          "selected": false,
          "text": "desktop",
          "value": "desktop"
        }
      },
      "sparkline": {
        "fillColor": "rgba(31, 118, 189, 0.18)",
        "full": false,
        "lineColor": "rgb(31, 120, 193)",
        "show": false
      },
      "tableColumn": "",
      "targets": [
        {
          "expr": "pagespeed_lighthouse_category_score{env=\"ops\", host=\"$host\",path=\"$path\",strategy=\"$strategy\",category=\"performance\"} * 100",
          "format": "time_series",
          "intervalFactor": 1,
          "legendFormat": "",
          "refId": "A"
        }
      ],
      "thresholds": "50,90",
      "title": "Performance Score",
      "transparent": true,
      "type": "singlestat",
      "valueFontSize": "80%",
      "valueMaps": [
        {
          "op": "=",
          "text": "N/A",
          "value": "null"
        }
      ],
      "valueName": "current"
    },
    {
      "cacheTimeout": null,
      "colorBackground": false,
      "colorPostfix": false,
      "colorPrefix": false,
      "colorValue": true,
      "colors": [
        "#d44a3a",
        "rgba(237, 129, 40, 0.89)",
        "#299c46"
      ],
      "datasource": "Global",
      "description": "The Accessibility score is a weighted average of all the accessibility audits. See Scoring Details for a full list of how each audit is weighted. The heavier-weighted audits have a bigger impact on your score.\n\nEach accessibility audit is pass or fail. Unlike the Performance audits, a page doesn't get points for partially passing an accessibility audit. For example, if some elements have screenreader-friendly names, but others don't, that page gets a 0 for the screenreader-friendly-names audit.",
      "fieldConfig": {
        "defaults": {
          "custom": {}
        },
        "overrides": []
      },
      "format": "none",
      "gauge": {
        "maxValue": 100,
        "minValue": 0,
        "show": true,
        "thresholdLabels": false,
        "thresholdMarkers": true
      },
      "gridPos": {
        "h": 4,
        "w": 4,
        "x": 8,
        "y": 1
      },
      "id": 18,
      "interval": null,
      "links": [],
      "mappingType": 1,
      "mappingTypes": [
        {
          "name": "value to text",
          "value": 1
        },
        {
          "name": "range to text",
          "value": 2
        }
      ],
      "maxDataPoints": 100,
      "maxPerRow": 4,
      "nullPointMode": "connected",
      "nullText": null,
      "postfix": "",
      "postfixFontSize": "50%",
      "prefix": "",
      "prefixFontSize": "50%",
      "rangeMaps": [
        {
          "from": "null",
          "text": "N/A",
          "to": "null"
        }
      ],
      "repeatDirection": "h",
      "scopedVars": {
        "strategy": {
          "selected": false,
          "text": "desktop",
          "value": "desktop"
        }
      },
      "sparkline": {
        "fillColor": "rgba(31, 118, 189, 0.18)",
        "full": false,
        "lineColor": "rgb(31, 120, 193)",
        "show": false
      },
      "tableColumn": "",
      "targets": [
        {
          "expr": "pagespeed_lighthouse_category_score{env=\"ops\", host=\"$host\",path=\"$path\",strategy=\"$strategy\",category=\"accessibility\"} * 100",
          "format": "time_series",
          "intervalFactor": 1,
          "legendFormat": "",
          "refId": "A"
        }
      ],
      "thresholds": "50,90",
      "title": "Accessibility Score",
      "transparent": true,
      "type": "singlestat",
      "valueFontSize": "80%",
      "valueMaps": [
        {
          "op": "=",
          "text": "N/A",
          "value": "null"
        }
      ],
      "valueName": "current"
    },
    {
      "cacheTimeout": null,
      "colorBackground": false,
      "colorPostfix": false,
      "colorPrefix": false,
      "colorValue": true,
      "colors": [
        "#d44a3a",
        "rgba(237, 129, 40, 0.89)",
        "#299c46"
      ],
      "datasource": "Global",
      "description": "Lighthouse returns a Progressive Web App (PWA) score between 0 and 100. 0 is the worst possible score, and 100 is the best.\n\nThe PWA audits are based on the Baseline PWA Checklist, which lists 14 requirements. Lighthouse has automated audits for 11 of the 14 requirements. The remaining 3 can only be tested manually. Each of the 11 automated PWA audits are weighted equally, so each one contributes approximately 9 points to your PWA score.",
      "fieldConfig": {
        "defaults": {
          "custom": {}
        },
        "overrides": []
      },
      "format": "none",
      "gauge": {
        "maxValue": 100,
        "minValue": 0,
        "show": true,
        "thresholdLabels": false,
        "thresholdMarkers": true
      },
      "gridPos": {
        "h": 4,
        "w": 4,
        "x": 12,
        "y": 1
      },
      "id": 13,
      "interval": null,
      "links": [],
      "mappingType": 1,
      "mappingTypes": [
        {
          "name": "value to text",
          "value": 1
        },
        {
          "name": "range to text",
          "value": 2
        }
      ],
      "maxDataPoints": 100,
      "maxPerRow": 4,
      "nullPointMode": "connected",
      "nullText": null,
      "postfix": "",
      "postfixFontSize": "50%",
      "prefix": "",
      "prefixFontSize": "50%",
      "rangeMaps": [
        {
          "from": "null",
          "text": "N/A",
          "to": "null"
        }
      ],
      "repeatDirection": "h",
      "scopedVars": {
        "strategy": {
          "selected": false,
          "text": "desktop",
          "value": "desktop"
        }
      },
      "sparkline": {
        "fillColor": "rgba(31, 118, 189, 0.18)",
        "full": false,
        "lineColor": "rgb(31, 120, 193)",
        "show": false
      },
      "tableColumn": "",
      "targets": [
        {
          "expr": "pagespeed_lighthouse_category_score{env=\"ops\", host=\"$host\",path=\"$path\",strategy=\"$strategy\",category=\"pwa\"} * 100",
          "format": "time_series",
          "intervalFactor": 1,
          "legendFormat": "",
          "refId": "A"
        }
      ],
      "thresholds": "50,90",
      "title": "PWA Score",
      "transparent": true,
      "type": "singlestat",
      "valueFontSize": "80%",
      "valueMaps": [
        {
          "op": "=",
          "text": "N/A",
          "value": "null"
        }
      ],
      "valueName": "current"
    },
    {
      "cacheTimeout": null,
      "colorBackground": false,
      "colorPostfix": false,
      "colorPrefix": false,
      "colorValue": true,
      "colors": [
        "#d44a3a",
        "rgba(237, 129, 40, 0.89)",
        "#299c46"
      ],
      "datasource": "Global",
      "description": "Search Engine Optimization Score",
      "fieldConfig": {
        "defaults": {
          "custom": {}
        },
        "overrides": []
      },
      "format": "none",
      "gauge": {
        "maxValue": 100,
        "minValue": 0,
        "show": true,
        "thresholdLabels": false,
        "thresholdMarkers": true
      },
      "gridPos": {
        "h": 4,
        "w": 4,
        "x": 16,
        "y": 1
      },
      "id": 10,
      "interval": null,
      "links": [],
      "mappingType": 1,
      "mappingTypes": [
        {
          "name": "value to text",
          "value": 1
        },
        {
          "name": "range to text",
          "value": 2
        }
      ],
      "maxDataPoints": 100,
      "maxPerRow": 4,
      "nullPointMode": "connected",
      "nullText": null,
      "postfix": "",
      "postfixFontSize": "50%",
      "prefix": "",
      "prefixFontSize": "50%",
      "rangeMaps": [
        {
          "from": "null",
          "text": "N/A",
          "to": "null"
        }
      ],
      "repeat": null,
      "repeatDirection": "h",
      "scopedVars": {
        "strategy": {
          "selected": false,
          "text": "desktop",
          "value": "desktop"
        }
      },
      "sparkline": {
        "fillColor": "rgba(31, 118, 189, 0.18)",
        "full": false,
        "lineColor": "rgb(31, 120, 193)",
        "show": false
      },
      "tableColumn": "",
      "targets": [
        {
          "expr": "pagespeed_lighthouse_category_score{env=\"ops\", host=\"$host\",path=\"$path\",strategy=\"$strategy\",category=\"seo\"} * 100",
          "format": "time_series",
          "intervalFactor": 1,
          "legendFormat": "",
          "refId": "A"
        }
      ],
      "thresholds": "50,90",
      "title": "SEO Score",
      "transparent": true,
      "type": "singlestat",
      "valueFontSize": "80%",
      "valueMaps": [
        {
          "op": "=",
          "text": "N/A",
          "value": "null"
        }
      ],
      "valueName": "current"
    },
    {
      "cacheTimeout": null,
      "colorBackground": false,
      "colorPostfix": false,
      "colorPrefix": false,
      "colorValue": true,
      "colors": [
        "#d44a3a",
        "rgba(237, 129, 40, 0.89)",
        "#299c46"
      ],
      "datasource": "Global",
      "description": "Lighthouse returns a Best Practices score between 0 and 100. 0 is the worst possible score, and 100 is the best.\n\nThe Best Practices audits are equally weighted. To calculate how much each audit contributes to your overall Best Practices score, count the number of Best Practices audits, then divide 100 by that number.",
      "fieldConfig": {
        "defaults": {
          "custom": {}
        },
        "overrides": []
      },
      "format": "none",
      "gauge": {
        "maxValue": 100,
        "minValue": 0,
        "show": true,
        "thresholdLabels": false,
        "thresholdMarkers": true
      },
      "gridPos": {
        "h": 4,
        "w": 4,
        "x": 20,
        "y": 1
      },
      "id": 19,
      "interval": null,
      "links": [],
      "mappingType": 1,
      "mappingTypes": [
        {
          "name": "value to text",
          "value": 1
        },
        {
          "name": "range to text",
          "value": 2
        }
      ],
      "maxDataPoints": 100,
      "maxPerRow": 4,
      "nullPointMode": "connected",
      "nullText": null,
      "postfix": "",
      "postfixFontSize": "50%",
      "prefix": "",
      "prefixFontSize": "50%",
      "rangeMaps": [
        {
          "from": "null",
          "text": "N/A",
          "to": "null"
        }
      ],
      "repeatDirection": "h",
      "scopedVars": {
        "strategy": {
          "selected": false,
          "text": "desktop",
          "value": "desktop"
        }
      },
      "sparkline": {
        "fillColor": "rgba(31, 118, 189, 0.18)",
        "full": false,
        "lineColor": "rgb(31, 120, 193)",
        "show": false
      },
      "tableColumn": "",
      "targets": [
        {
          "expr": "pagespeed_lighthouse_category_score{env=\"ops\", host=\"$host\",path=\"$path\",strategy=\"$strategy\",category=\"best-practices\"} * 100",
          "format": "time_series",
          "intervalFactor": 1,
          "legendFormat": "",
          "refId": "A"
        }
      ],
      "thresholds": "50,90",
      "title": "Best Practices Score",
      "transparent": true,
      "type": "singlestat",
      "valueFontSize": "80%",
      "valueMaps": [
        {
          "op": "=",
          "text": "N/A",
          "value": "null"
        }
      ],
      "valueName": "current"
    },
    {
      "collapsed": false,
      "datasource": null,
      "gridPos": {
        "h": 1,
        "w": 24,
        "x": 0,
        "y": 5
      },
      "id": 67,
      "panels": [],
      "repeat": null,
      "repeatIteration": 1596721822575,
      "repeatPanelId": 6,
      "scopedVars": {
        "strategy": {
          "selected": false,
          "text": "mobile",
          "value": "mobile"
        }
      },
      "title": "Overview ($strategy)",
      "type": "row"
    },
    {
      "content": "#### Lighthouse scores for $strategy\n* 0 to 49 (slow): Red\n* 50 to 89 (average): Orange\n* 90 to 100 (fast): Green\n",
      "datasource": null,
      "fieldConfig": {
        "defaults": {
          "custom": {}
        },
        "overrides": []
      },
      "gridPos": {
        "h": 4,
        "w": 4,
        "x": 0,
        "y": 6
      },
      "id": 68,
      "links": [],
      "mode": "markdown",
      "repeatIteration": 1596721822575,
      "repeatPanelId": 27,
      "repeatedByRow": true,
      "scopedVars": {
        "strategy": {
          "selected": false,
          "text": "mobile",
          "value": "mobile"
        }
      },
      "title": "",
      "transparent": true,
      "type": "text"
    },
    {
      "cacheTimeout": null,
      "colorBackground": false,
      "colorPostfix": false,
      "colorPrefix": false,
      "colorValue": true,
      "colors": [
        "#d44a3a",
        "rgba(237, 129, 40, 0.89)",
        "#299c46"
      ],
      "datasource": "Global",
      "description": "Performance Score",
      "fieldConfig": {
        "defaults": {
          "custom": {}
        },
        "overrides": []
      },
      "format": "none",
      "gauge": {
        "maxValue": 100,
        "minValue": 0,
        "show": true,
        "thresholdLabels": false,
        "thresholdMarkers": true
      },
      "gridPos": {
        "h": 4,
        "w": 4,
        "x": 4,
        "y": 6
      },
      "id": 69,
      "interval": null,
      "links": [],
      "mappingType": 1,
      "mappingTypes": [
        {
          "name": "value to text",
          "value": 1
        },
        {
          "name": "range to text",
          "value": 2
        }
      ],
      "maxDataPoints": 100,
      "maxPerRow": 4,
      "nullPointMode": "connected",
      "nullText": null,
      "postfix": "",
      "postfixFontSize": "50%",
      "prefix": "",
      "prefixFontSize": "50%",
      "rangeMaps": [
        {
          "from": "null",
          "text": "N/A",
          "to": "null"
        }
      ],
      "repeatDirection": "h",
      "repeatIteration": 1596721822575,
      "repeatPanelId": 17,
      "repeatedByRow": true,
      "scopedVars": {
        "strategy": {
          "selected": false,
          "text": "mobile",
          "value": "mobile"
        }
      },
      "sparkline": {
        "fillColor": "rgba(31, 118, 189, 0.18)",
        "full": false,
        "lineColor": "rgb(31, 120, 193)",
        "show": false
      },
      "tableColumn": "",
      "targets": [
        {
          "expr": "pagespeed_lighthouse_category_score{env=\"ops\", host=\"$host\",path=\"$path\",strategy=\"$strategy\",category=\"performance\"} * 100",
          "format": "time_series",
          "intervalFactor": 1,
          "legendFormat": "",
          "refId": "A"
        }
      ],
      "thresholds": "50,90",
      "title": "Performance Score",
      "transparent": true,
      "type": "singlestat",
      "valueFontSize": "80%",
      "valueMaps": [
        {
          "op": "=",
          "text": "N/A",
          "value": "null"
        }
      ],
      "valueName": "current"
    },
    {
      "cacheTimeout": null,
      "colorBackground": false,
      "colorPostfix": false,
      "colorPrefix": false,
      "colorValue": true,
      "colors": [
        "#d44a3a",
        "rgba(237, 129, 40, 0.89)",
        "#299c46"
      ],
      "datasource": "Global",
      "description": "The Accessibility score is a weighted average of all the accessibility audits. See Scoring Details for a full list of how each audit is weighted. The heavier-weighted audits have a bigger impact on your score.\n\nEach accessibility audit is pass or fail. Unlike the Performance audits, a page doesn't get points for partially passing an accessibility audit. For example, if some elements have screenreader-friendly names, but others don't, that page gets a 0 for the screenreader-friendly-names audit.",
      "fieldConfig": {
        "defaults": {
          "custom": {}
        },
        "overrides": []
      },
      "format": "none",
      "gauge": {
        "maxValue": 100,
        "minValue": 0,
        "show": true,
        "thresholdLabels": false,
        "thresholdMarkers": true
      },
      "gridPos": {
        "h": 4,
        "w": 4,
        "x": 8,
        "y": 6
      },
      "id": 70,
      "interval": null,
      "links": [],
      "mappingType": 1,
      "mappingTypes": [
        {
          "name": "value to text",
          "value": 1
        },
        {
          "name": "range to text",
          "value": 2
        }
      ],
      "maxDataPoints": 100,
      "maxPerRow": 4,
      "nullPointMode": "connected",
      "nullText": null,
      "postfix": "",
      "postfixFontSize": "50%",
      "prefix": "",
      "prefixFontSize": "50%",
      "rangeMaps": [
        {
          "from": "null",
          "text": "N/A",
          "to": "null"
        }
      ],
      "repeatDirection": "h",
      "repeatIteration": 1596721822575,
      "repeatPanelId": 18,
      "repeatedByRow": true,
      "scopedVars": {
        "strategy": {
          "selected": false,
          "text": "mobile",
          "value": "mobile"
        }
      },
      "sparkline": {
        "fillColor": "rgba(31, 118, 189, 0.18)",
        "full": false,
        "lineColor": "rgb(31, 120, 193)",
        "show": false
      },
      "tableColumn": "",
      "targets": [
        {
          "expr": "pagespeed_lighthouse_category_score{env=\"ops\", host=\"$host\",path=\"$path\",strategy=\"$strategy\",category=\"accessibility\"} * 100",
          "format": "time_series",
          "intervalFactor": 1,
          "legendFormat": "",
          "refId": "A"
        }
      ],
      "thresholds": "50,90",
      "title": "Accessibility Score",
      "transparent": true,
      "type": "singlestat",
      "valueFontSize": "80%",
      "valueMaps": [
        {
          "op": "=",
          "text": "N/A",
          "value": "null"
        }
      ],
      "valueName": "current"
    },
    {
      "cacheTimeout": null,
      "colorBackground": false,
      "colorPostfix": false,
      "colorPrefix": false,
      "colorValue": true,
      "colors": [
        "#d44a3a",
        "rgba(237, 129, 40, 0.89)",
        "#299c46"
      ],
      "datasource": "Global",
      "description": "Lighthouse returns a Progressive Web App (PWA) score between 0 and 100. 0 is the worst possible score, and 100 is the best.\n\nThe PWA audits are based on the Baseline PWA Checklist, which lists 14 requirements. Lighthouse has automated audits for 11 of the 14 requirements. The remaining 3 can only be tested manually. Each of the 11 automated PWA audits are weighted equally, so each one contributes approximately 9 points to your PWA score.",
      "fieldConfig": {
        "defaults": {
          "custom": {}
        },
        "overrides": []
      },
      "format": "none",
      "gauge": {
        "maxValue": 100,
        "minValue": 0,
        "show": true,
        "thresholdLabels": false,
        "thresholdMarkers": true
      },
      "gridPos": {
        "h": 4,
        "w": 4,
        "x": 12,
        "y": 6
      },
      "id": 71,
      "interval": null,
      "links": [],
      "mappingType": 1,
      "mappingTypes": [
        {
          "name": "value to text",
          "value": 1
        },
        {
          "name": "range to text",
          "value": 2
        }
      ],
      "maxDataPoints": 100,
      "maxPerRow": 4,
      "nullPointMode": "connected",
      "nullText": null,
      "postfix": "",
      "postfixFontSize": "50%",
      "prefix": "",
      "prefixFontSize": "50%",
      "rangeMaps": [
        {
          "from": "null",
          "text": "N/A",
          "to": "null"
        }
      ],
      "repeatDirection": "h",
      "repeatIteration": 1596721822575,
      "repeatPanelId": 13,
      "repeatedByRow": true,
      "scopedVars": {
        "strategy": {
          "selected": false,
          "text": "mobile",
          "value": "mobile"
        }
      },
      "sparkline": {
        "fillColor": "rgba(31, 118, 189, 0.18)",
        "full": false,
        "lineColor": "rgb(31, 120, 193)",
        "show": false
      },
      "tableColumn": "",
      "targets": [
        {
          "expr": "pagespeed_lighthouse_category_score{env=\"ops\", host=\"$host\",path=\"$path\",strategy=\"$strategy\",category=\"pwa\"} * 100",
          "format": "time_series",
          "intervalFactor": 1,
          "legendFormat": "",
          "refId": "A"
        }
      ],
      "thresholds": "50,90",
      "title": "PWA Score",
      "transparent": true,
      "type": "singlestat",
      "valueFontSize": "80%",
      "valueMaps": [
        {
          "op": "=",
          "text": "N/A",
          "value": "null"
        }
      ],
      "valueName": "current"
    },
    {
      "cacheTimeout": null,
      "colorBackground": false,
      "colorPostfix": false,
      "colorPrefix": false,
      "colorValue": true,
      "colors": [
        "#d44a3a",
        "rgba(237, 129, 40, 0.89)",
        "#299c46"
      ],
      "datasource": "Global",
      "description": "Search Engine Optimization Score",
      "fieldConfig": {
        "defaults": {
          "custom": {}
        },
        "overrides": []
      },
      "format": "none",
      "gauge": {
        "maxValue": 100,
        "minValue": 0,
        "show": true,
        "thresholdLabels": false,
        "thresholdMarkers": true
      },
      "gridPos": {
        "h": 4,
        "w": 4,
        "x": 16,
        "y": 6
      },
      "id": 72,
      "interval": null,
      "links": [],
      "mappingType": 1,
      "mappingTypes": [
        {
          "name": "value to text",
          "value": 1
        },
        {
          "name": "range to text",
          "value": 2
        }
      ],
      "maxDataPoints": 100,
      "maxPerRow": 4,
      "nullPointMode": "connected",
      "nullText": null,
      "postfix": "",
      "postfixFontSize": "50%",
      "prefix": "",
      "prefixFontSize": "50%",
      "rangeMaps": [
        {
          "from": "null",
          "text": "N/A",
          "to": "null"
        }
      ],
      "repeat": null,
      "repeatDirection": "h",
      "repeatIteration": 1596721822575,
      "repeatPanelId": 10,
      "repeatedByRow": true,
      "scopedVars": {
        "strategy": {
          "selected": false,
          "text": "mobile",
          "value": "mobile"
        }
      },
      "sparkline": {
        "fillColor": "rgba(31, 118, 189, 0.18)",
        "full": false,
        "lineColor": "rgb(31, 120, 193)",
        "show": false
      },
      "tableColumn": "",
      "targets": [
        {
          "expr": "pagespeed_lighthouse_category_score{env=\"ops\", host=\"$host\",path=\"$path\",strategy=\"$strategy\",category=\"seo\"} * 100",
          "format": "time_series",
          "intervalFactor": 1,
          "legendFormat": "",
          "refId": "A"
        }
      ],
      "thresholds": "50,90",
      "title": "SEO Score",
      "transparent": true,
      "type": "singlestat",
      "valueFontSize": "80%",
      "valueMaps": [
        {
          "op": "=",
          "text": "N/A",
          "value": "null"
        }
      ],
      "valueName": "current"
    },
    {
      "cacheTimeout": null,
      "colorBackground": false,
      "colorPostfix": false,
      "colorPrefix": false,
      "colorValue": true,
      "colors": [
        "#d44a3a",
        "rgba(237, 129, 40, 0.89)",
        "#299c46"
      ],
      "datasource": "Global",
      "description": "Lighthouse returns a Best Practices score between 0 and 100. 0 is the worst possible score, and 100 is the best.\n\nThe Best Practices audits are equally weighted. To calculate how much each audit contributes to your overall Best Practices score, count the number of Best Practices audits, then divide 100 by that number.",
      "fieldConfig": {
        "defaults": {
          "custom": {}
        },
        "overrides": []
      },
      "format": "none",
      "gauge": {
        "maxValue": 100,
        "minValue": 0,
        "show": true,
        "thresholdLabels": false,
        "thresholdMarkers": true
      },
      "gridPos": {
        "h": 4,
        "w": 4,
        "x": 20,
        "y": 6
      },
      "id": 73,
      "interval": null,
      "links": [],
      "mappingType": 1,
      "mappingTypes": [
        {
          "name": "value to text",
          "value": 1
        },
        {
          "name": "range to text",
          "value": 2
        }
      ],
      "maxDataPoints": 100,
      "maxPerRow": 4,
      "nullPointMode": "connected",
      "nullText": null,
      "postfix": "",
      "postfixFontSize": "50%",
      "prefix": "",
      "prefixFontSize": "50%",
      "rangeMaps": [
        {
          "from": "null",
          "text": "N/A",
          "to": "null"
        }
      ],
      "repeatDirection": "h",
      "repeatIteration": 1596721822575,
      "repeatPanelId": 19,
      "repeatedByRow": true,
      "scopedVars": {
        "strategy": {
          "selected": false,
          "text": "mobile",
          "value": "mobile"
        }
      },
      "sparkline": {
        "fillColor": "rgba(31, 118, 189, 0.18)",
        "full": false,
        "lineColor": "rgb(31, 120, 193)",
        "show": false
      },
      "tableColumn": "",
      "targets": [
        {
          "expr": "pagespeed_lighthouse_category_score{env=\"ops\", host=\"$host\",path=\"$path\",strategy=\"$strategy\",category=\"best-practices\"} * 100",
          "format": "time_series",
          "intervalFactor": 1,
          "legendFormat": "",
          "refId": "A"
        }
      ],
      "thresholds": "50,90",
      "title": "Best Practices Score",
      "transparent": true,
      "type": "singlestat",
      "valueFontSize": "80%",
      "valueMaps": [
        {
          "op": "=",
          "text": "N/A",
          "value": "null"
        }
      ],
      "valueName": "current"
    },
    {
      "collapsed": true,
      "datasource": null,
      "gridPos": {
        "h": 1,
        "w": 24,
        "x": 0,
        "y": 10
      },
      "id": 66,
      "panels": [
        {
          "aliasColors": {},
          "bars": false,
          "dashLength": 10,
          "dashes": false,
          "datasource": "Global",
          "fill": 1,
          "gridPos": {
            "h": 8,
            "w": 12,
            "x": 0,
            "y": 11
          },
          "id": 45,
          "legend": {
            "alignAsTable": true,
            "avg": true,
            "current": true,
            "max": false,
            "min": false,
            "rightSide": true,
            "show": true,
            "total": false,
            "values": true
          },
          "lines": true,
          "linewidth": 1,
          "links": [],
          "maxPerRow": 2,
          "nullPointMode": "null",
          "percentage": false,
          "pointradius": 5,
          "points": false,
          "renderer": "flot",
          "repeat": null,
          "repeatDirection": "h",
          "scopedVars": {
            "strategy": {
              "selected": false,
              "text": "desktop",
              "value": "desktop"
            }
          },
          "seriesOverrides": [
            {
              "alias": "Total Time",
              "yaxis": 2
            }
          ],
          "spaceLength": 10,
          "stack": false,
          "steppedLine": false,
          "targets": [
            {
              "expr": "pagespeed_lighthouse_total_duration_seconds{env=\"ops\", host=\"$host\",path=\"$path\",strategy=\"$strategy\"}",
              "format": "time_series",
              "hide": false,
              "intervalFactor": 1,
              "legendFormat": "Total Time",
              "refId": "A"
            },
            {
              "expr": "pagespeed_lighthouse_first_contentful_paint_duration_seconds{env=\"ops\", host=\"$host\",path=\"$path\",strategy=\"$strategy\"}",
              "format": "time_series",
              "intervalFactor": 1,
              "legendFormat": "First Contentful Paint",
              "refId": "B"
            },
            {
              "expr": "pagespeed_lighthouse_first_cpu_idle_duration_seconds{env=\"ops\", host=\"$host\",path=\"$path\",strategy=\"$strategy\"}",
              "format": "time_series",
              "intervalFactor": 1,
              "legendFormat": "First CPU Idle",
              "refId": "C"
            },
            {
              "expr": "pagespeed_lighthouse_first_meaningful_paint_duration_seconds{env=\"ops\", host=\"$host\",path=\"$path\",strategy=\"$strategy\"}",
              "format": "time_series",
              "intervalFactor": 1,
              "legendFormat": "First Meaningful Paint",
              "refId": "D"
            },
            {
              "expr": "pagespeed_lighthouse_interactive_duration_seconds{env=\"ops\", host=\"$host\",path=\"$path\",strategy=\"$strategy\"}",
              "format": "time_series",
              "intervalFactor": 1,
              "legendFormat": "Interactive",
              "refId": "E"
            },
            {
              "expr": "pagespeed_lighthouse_speed_index_duration_seconds{env=\"ops\", host=\"$host\",path=\"$path\",strategy=\"$strategy\"}",
              "format": "time_series",
              "intervalFactor": 1,
              "legendFormat": "Content Speed Index ",
              "refId": "F"
            },
            {
              "expr": "pagespeed_lighthouse_bootup_time_duration_seconds{env=\"ops\", host=\"$host\",path=\"$path\",strategy=\"$strategy\"}",
              "format": "time_series",
              "intervalFactor": 1,
              "legendFormat": "JS Bootup Time",
              "refId": "G"
            }
          ],
          "thresholds": [],
          "timeFrom": null,
          "timeShift": null,
          "title": "Timings",
          "tooltip": {
            "shared": true,
            "sort": 0,
            "value_type": "individual"
          },
          "type": "graph",
          "xaxis": {
            "buckets": null,
            "mode": "time",
            "name": null,
            "show": true,
            "values": []
          },
          "yaxes": [
            {
              "decimals": null,
              "format": "s",
              "label": "",
              "logBase": 1,
              "max": null,
              "min": "0",
              "show": true
            },
            {
              "format": "s",
              "label": "",
              "logBase": 1,
              "max": null,
              "min": "0",
              "show": true
            }
          ],
          "yaxis": {
            "align": true,
            "alignLevel": 0
          }
        },
        {
          "aliasColors": {},
          "bars": false,
          "dashLength": 10,
          "dashes": false,
          "datasource": "Global",
          "fill": 1,
          "gridPos": {
            "h": 8,
            "w": 12,
            "x": 12,
            "y": 11
          },
          "id": 62,
          "legend": {
            "alignAsTable": true,
            "avg": true,
            "current": true,
            "max": false,
            "min": false,
            "rightSide": true,
            "show": true,
            "sideWidth": 400,
            "total": false,
            "values": true
          },
          "lines": true,
          "linewidth": 1,
          "links": [],
          "maxPerRow": 2,
          "nullPointMode": "null",
          "percentage": false,
          "pointradius": 5,
          "points": false,
          "renderer": "flot",
          "repeatDirection": "h",
          "scopedVars": {
            "strategy": {
              "selected": false,
              "text": "desktop",
              "value": "desktop"
            }
          },
          "seriesOverrides": [],
          "spaceLength": 10,
          "stack": false,
          "steppedLine": false,
          "targets": [
            {
              "expr": "delta(pagespeed_lighthouse_total_duration_seconds{env=\"ops\", host=\"$host\",path=\"$path\",strategy=\"$strategy\"}[$diff])",
              "format": "time_series",
              "hide": false,
              "intervalFactor": 1,
              "legendFormat": "Total Time",
              "refId": "A"
            },
            {
              "expr": "delta(pagespeed_lighthouse_first_contentful_paint_duration_seconds{env=\"ops\", host=\"$host\",path=\"$path\",strategy=\"$strategy\"}[$diff])",
              "format": "time_series",
              "intervalFactor": 1,
              "legendFormat": "First Contentful Paint",
              "refId": "B"
            },
            {
              "expr": "delta(pagespeed_lighthouse_first_cpu_idle_duration_seconds{env=\"ops\", host=\"$host\",path=\"$path\",strategy=\"$strategy\"}[$diff])",
              "format": "time_series",
              "intervalFactor": 1,
              "legendFormat": "First CPU Idle",
              "refId": "C"
            },
            {
              "expr": "delta(pagespeed_lighthouse_first_meaningful_paint_duration_seconds{env=\"ops\", host=\"$host\",path=\"$path\",strategy=\"$strategy\"}[$diff])",
              "format": "time_series",
              "intervalFactor": 1,
              "legendFormat": "First Meaningful Paint",
              "refId": "D"
            },
            {
              "expr": "delta(pagespeed_lighthouse_interactive_duration_seconds{env=\"ops\", host=\"$host\",path=\"$path\",strategy=\"$strategy\"}[$diff])",
              "format": "time_series",
              "intervalFactor": 1,
              "legendFormat": "Interactive",
              "refId": "E"
            },
            {
              "expr": "delta(pagespeed_lighthouse_speed_index_duration_seconds{env=\"ops\", host=\"$host\",path=\"$path\",strategy=\"$strategy\"}[$diff])",
              "format": "time_series",
              "intervalFactor": 1,
              "legendFormat": "Content Speed Index ",
              "refId": "F"
            },
            {
              "expr": "delta(pagespeed_lighthouse_bootup_time_duration_seconds{env=\"ops\", host=\"$host\",path=\"$path\",strategy=\"$strategy\"}[$diff])",
              "format": "time_series",
              "intervalFactor": 1,
              "legendFormat": "JS Bootup Time",
              "refId": "G"
            }
          ],
          "thresholds": [],
          "timeFrom": null,
          "timeShift": null,
          "title": "Timing Diff $diff",
          "tooltip": {
            "shared": true,
            "sort": 0,
            "value_type": "individual"
          },
          "type": "graph",
          "xaxis": {
            "buckets": null,
            "mode": "time",
            "name": null,
            "show": true,
            "values": []
          },
          "yaxes": [
            {
              "decimals": null,
              "format": "s",
              "label": "",
              "logBase": 1,
              "max": null,
              "min": null,
              "show": true
            },
            {
              "format": "s",
              "label": "",
              "logBase": 1,
              "max": null,
              "min": null,
              "show": true
            }
          ],
          "yaxis": {
            "align": false,
            "alignLevel": 0
          }
        },
        {
          "aliasColors": {},
          "bars": false,
          "dashLength": 10,
          "dashes": false,
          "datasource": "Global",
          "description": "https://developers.google.com/web/tools/lighthouse/v3/scoring",
          "fill": 1,
          "gridPos": {
            "h": 8,
            "w": 12,
            "x": 0,
            "y": 19
          },
          "id": 55,
          "legend": {
            "alignAsTable": true,
            "avg": false,
            "current": true,
            "max": false,
            "min": false,
            "rightSide": true,
            "show": true,
            "total": false,
            "values": true
          },
          "lines": true,
          "linewidth": 1,
          "links": [],
          "maxPerRow": 4,
          "nullPointMode": "null as zero",
          "percentage": false,
          "pointradius": 5,
          "points": false,
          "renderer": "flot",
          "repeat": null,
          "repeatDirection": "h",
          "scopedVars": {
            "strategy": {
              "selected": false,
              "text": "desktop",
              "value": "desktop"
            }
          },
          "seriesOverrides": [
            {
              "alias": "MAX",
              "fill": 0,
              "linewidth": 5,
              "stack": "B"
            }
          ],
          "spaceLength": 10,
          "stack": true,
          "steppedLine": false,
          "targets": [
            {
              "expr": "pagespeed_lighthouse_audit_score{env=\"ops\", host=\"$host\",path=\"$path\",strategy=\"$strategy\"}",
              "format": "time_series",
              "intervalFactor": 1,
              "legendFormat": "{{audit}}",
              "refId": "A"
            },
            {
              "expr": "count(pagespeed_lighthouse_audit_score{env=\"ops\", host=\"$host\",path=\"$path\",strategy=\"$strategy\"})",
              "format": "time_series",
              "hide": true,
              "intervalFactor": 1,
              "legendFormat": "MAX",
              "refId": "B"
            }
          ],
          "thresholds": [],
          "timeFrom": null,
          "timeShift": null,
          "title": "Audit Scores",
          "tooltip": {
            "shared": true,
            "sort": 0,
            "value_type": "individual"
          },
          "type": "graph",
          "xaxis": {
            "buckets": null,
            "mode": "time",
            "name": null,
            "show": true,
            "values": []
          },
          "yaxes": [
            {
              "decimals": 2,
              "format": "short",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": "0",
              "show": true
            },
            {
              "format": "short",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": "0",
              "show": true
            }
          ],
          "yaxis": {
            "align": false,
            "alignLevel": null
          }
        },
        {
          "aliasColors": {},
          "bars": false,
          "dashLength": 10,
          "dashes": false,
          "datasource": "Global",
          "description": "https://developers.google.com/web/tools/lighthouse/v3/scoring",
          "fill": 1,
          "gridPos": {
            "h": 8,
            "w": 12,
            "x": 12,
            "y": 19
          },
          "id": 63,
          "legend": {
            "alignAsTable": true,
            "avg": true,
            "current": true,
            "max": false,
            "min": false,
            "rightSide": true,
            "show": true,
            "sideWidth": 400,
            "total": false,
            "values": true
          },
          "lines": true,
          "linewidth": 1,
          "links": [],
          "maxPerRow": 4,
          "nullPointMode": "null as zero",
          "percentage": false,
          "pointradius": 5,
          "points": false,
          "renderer": "flot",
          "repeatDirection": "h",
          "scopedVars": {
            "strategy": {
              "selected": false,
              "text": "desktop",
              "value": "desktop"
            }
          },
          "seriesOverrides": [
            {
              "alias": "MAX",
              "fill": 0,
              "linewidth": 5,
              "stack": "B"
            }
          ],
          "spaceLength": 10,
          "stack": true,
          "steppedLine": false,
          "targets": [
            {
              "expr": "delta(pagespeed_lighthouse_audit_score{env=\"ops\", host=\"$host\",path=\"$path\",strategy=\"$strategy\"}[$diff])",
              "format": "time_series",
              "intervalFactor": 1,
              "legendFormat": "{{audit}}",
              "refId": "A"
            }
          ],
          "thresholds": [],
          "timeFrom": null,
          "timeShift": null,
          "title": "Audit Diff $diff",
          "tooltip": {
            "shared": true,
            "sort": 0,
            "value_type": "individual"
          },
          "type": "graph",
          "xaxis": {
            "buckets": null,
            "mode": "time",
            "name": null,
            "show": true,
            "values": []
          },
          "yaxes": [
            {
              "decimals": 2,
              "format": "short",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": null,
              "show": true
            },
            {
              "format": "short",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": null,
              "show": true
            }
          ],
          "yaxis": {
            "align": false,
            "alignLevel": null
          }
        },
        {
          "aliasColors": {},
          "bars": false,
          "dashLength": 10,
          "dashes": false,
          "datasource": "Global",
          "fill": 1,
          "gridPos": {
            "h": 8,
            "w": 12,
            "x": 0,
            "y": 27
          },
          "id": 57,
          "legend": {
            "alignAsTable": true,
            "avg": true,
            "current": true,
            "max": true,
            "min": true,
            "rightSide": true,
            "show": true,
            "total": false,
            "values": true
          },
          "lines": true,
          "linewidth": 1,
          "links": [],
          "nullPointMode": "null",
          "percentage": false,
          "pointradius": 5,
          "points": false,
          "renderer": "flot",
          "scopedVars": {
            "strategy": {
              "selected": false,
              "text": "desktop",
              "value": "desktop"
            }
          },
          "seriesOverrides": [],
          "spaceLength": 10,
          "stack": false,
          "steppedLine": false,
          "targets": [
            {
              "expr": "pagespeed_lighthouse_category_score{env=\"ops\", host=\"$host\",path=\"$path\",strategy=\"$strategy\"}*100 ",
              "format": "time_series",
              "intervalFactor": 1,
              "legendFormat": "{{category}}",
              "refId": "A"
            }
          ],
          "thresholds": [],
          "timeFrom": null,
          "timeShift": null,
          "title": "Score History",
          "tooltip": {
            "shared": true,
            "sort": 0,
            "value_type": "individual"
          },
          "type": "graph",
          "xaxis": {
            "buckets": null,
            "mode": "time",
            "name": null,
            "show": true,
            "values": []
          },
          "yaxes": [
            {
              "decimals": 2,
              "format": "percent",
              "label": null,
              "logBase": 1,
              "max": "100",
              "min": "0",
              "show": true
            },
            {
              "decimals": 2,
              "format": "short",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": null,
              "show": true
            }
          ],
          "yaxis": {
            "align": false,
            "alignLevel": null
          }
        },
        {
          "aliasColors": {},
          "bars": false,
          "dashLength": 10,
          "dashes": false,
          "datasource": "Global",
          "decimals": 2,
          "fill": 1,
          "gridPos": {
            "h": 8,
            "w": 12,
            "x": 12,
            "y": 27
          },
          "id": 64,
          "legend": {
            "alignAsTable": true,
            "avg": true,
            "current": true,
            "max": false,
            "min": false,
            "rightSide": true,
            "show": true,
            "sideWidth": 400,
            "total": false,
            "values": true
          },
          "lines": true,
          "linewidth": 1,
          "links": [],
          "nullPointMode": "null",
          "percentage": false,
          "pointradius": 5,
          "points": false,
          "renderer": "flot",
          "scopedVars": {
            "strategy": {
              "selected": false,
              "text": "desktop",
              "value": "desktop"
            }
          },
          "seriesOverrides": [],
          "spaceLength": 10,
          "stack": false,
          "steppedLine": false,
          "targets": [
            {
              "expr": "delta(pagespeed_lighthouse_category_score{env=\"ops\", host=\"$host\",path=\"$path\",strategy=\"$strategy\"}[$diff])*100",
              "format": "time_series",
              "intervalFactor": 1,
              "legendFormat": "{{category}}",
              "refId": "A"
            }
          ],
          "thresholds": [],
          "timeFrom": null,
          "timeShift": null,
          "title": "Score History Diff $diff",
          "tooltip": {
            "shared": true,
            "sort": 0,
            "value_type": "individual"
          },
          "type": "graph",
          "xaxis": {
            "buckets": null,
            "mode": "time",
            "name": null,
            "show": true,
            "values": []
          },
          "yaxes": [
            {
              "decimals": null,
              "format": "percent",
              "label": null,
              "logBase": 1,
              "max": "100",
              "min": "-100",
              "show": true
            },
            {
              "decimals": null,
              "format": "short",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": null,
              "show": true
            }
          ],
          "yaxis": {
            "align": false,
            "alignLevel": null
          }
        }
      ],
      "repeat": "strategy",
      "scopedVars": {
        "strategy": {
          "selected": false,
          "text": "desktop",
          "value": "desktop"
        }
      },
      "title": "Timings / Scores / Audits ($strategy)",
      "type": "row"
    },
    {
      "collapsed": true,
      "datasource": null,
      "gridPos": {
        "h": 1,
        "w": 24,
        "x": 0,
        "y": 11
      },
      "id": 74,
      "panels": [
        {
          "aliasColors": {},
          "bars": false,
          "dashLength": 10,
          "dashes": false,
          "datasource": "Global",
          "fill": 1,
          "gridPos": {
            "h": 8,
            "w": 12,
            "x": 0,
            "y": 11
          },
          "id": 75,
          "legend": {
            "alignAsTable": true,
            "avg": true,
            "current": true,
            "max": false,
            "min": false,
            "rightSide": true,
            "show": true,
            "total": false,
            "values": true
          },
          "lines": true,
          "linewidth": 1,
          "links": [],
          "maxPerRow": 2,
          "nullPointMode": "null",
          "percentage": false,
          "pointradius": 5,
          "points": false,
          "renderer": "flot",
          "repeat": null,
          "repeatDirection": "h",
          "repeatIteration": 1596721822575,
          "repeatPanelId": 45,
          "repeatedByRow": true,
          "scopedVars": {
            "strategy": {
              "selected": false,
              "text": "mobile",
              "value": "mobile"
            }
          },
          "seriesOverrides": [
            {
              "alias": "Total Time",
              "yaxis": 2
            }
          ],
          "spaceLength": 10,
          "stack": false,
          "steppedLine": false,
          "targets": [
            {
              "expr": "pagespeed_lighthouse_total_duration_seconds{env=\"ops\", host=\"$host\",path=\"$path\",strategy=\"$strategy\"}",
              "format": "time_series",
              "hide": false,
              "intervalFactor": 1,
              "legendFormat": "Total Time",
              "refId": "A"
            },
            {
              "expr": "pagespeed_lighthouse_first_contentful_paint_duration_seconds{env=\"ops\", host=\"$host\",path=\"$path\",strategy=\"$strategy\"}",
              "format": "time_series",
              "intervalFactor": 1,
              "legendFormat": "First Contentful Paint",
              "refId": "B"
            },
            {
              "expr": "pagespeed_lighthouse_first_cpu_idle_duration_seconds{env=\"ops\", host=\"$host\",path=\"$path\",strategy=\"$strategy\"}",
              "format": "time_series",
              "intervalFactor": 1,
              "legendFormat": "First CPU Idle",
              "refId": "C"
            },
            {
              "expr": "pagespeed_lighthouse_first_meaningful_paint_duration_seconds{env=\"ops\", host=\"$host\",path=\"$path\",strategy=\"$strategy\"}",
              "format": "time_series",
              "intervalFactor": 1,
              "legendFormat": "First Meaningful Paint",
              "refId": "D"
            },
            {
              "expr": "pagespeed_lighthouse_interactive_duration_seconds{env=\"ops\", host=\"$host\",path=\"$path\",strategy=\"$strategy\"}",
              "format": "time_series",
              "intervalFactor": 1,
              "legendFormat": "Interactive",
              "refId": "E"
            },
            {
              "expr": "pagespeed_lighthouse_speed_index_duration_seconds{env=\"ops\", host=\"$host\",path=\"$path\",strategy=\"$strategy\"}",
              "format": "time_series",
              "intervalFactor": 1,
              "legendFormat": "Content Speed Index ",
              "refId": "F"
            },
            {
              "expr": "pagespeed_lighthouse_bootup_time_duration_seconds{env=\"ops\", host=\"$host\",path=\"$path\",strategy=\"$strategy\"}",
              "format": "time_series",
              "intervalFactor": 1,
              "legendFormat": "JS Bootup Time",
              "refId": "G"
            }
          ],
          "thresholds": [],
          "timeFrom": null,
          "timeShift": null,
          "title": "Timings",
          "tooltip": {
            "shared": true,
            "sort": 0,
            "value_type": "individual"
          },
          "type": "graph",
          "xaxis": {
            "buckets": null,
            "mode": "time",
            "name": null,
            "show": true,
            "values": []
          },
          "yaxes": [
            {
              "decimals": null,
              "format": "s",
              "label": "",
              "logBase": 1,
              "max": null,
              "min": "0",
              "show": true
            },
            {
              "format": "s",
              "label": "",
              "logBase": 1,
              "max": null,
              "min": "0",
              "show": true
            }
          ],
          "yaxis": {
            "align": true,
            "alignLevel": 0
          }
        },
        {
          "aliasColors": {},
          "bars": false,
          "dashLength": 10,
          "dashes": false,
          "datasource": "Global",
          "fill": 1,
          "gridPos": {
            "h": 8,
            "w": 12,
            "x": 12,
            "y": 11
          },
          "id": 76,
          "legend": {
            "alignAsTable": true,
            "avg": true,
            "current": true,
            "max": false,
            "min": false,
            "rightSide": true,
            "show": true,
            "sideWidth": 400,
            "total": false,
            "values": true
          },
          "lines": true,
          "linewidth": 1,
          "links": [],
          "maxPerRow": 2,
          "nullPointMode": "null",
          "percentage": false,
          "pointradius": 5,
          "points": false,
          "renderer": "flot",
          "repeatDirection": "h",
          "repeatIteration": 1596721822575,
          "repeatPanelId": 62,
          "repeatedByRow": true,
          "scopedVars": {
            "strategy": {
              "selected": false,
              "text": "mobile",
              "value": "mobile"
            }
          },
          "seriesOverrides": [],
          "spaceLength": 10,
          "stack": false,
          "steppedLine": false,
          "targets": [
            {
              "expr": "delta(pagespeed_lighthouse_total_duration_seconds{env=\"ops\", host=\"$host\",path=\"$path\",strategy=\"$strategy\"}[$diff])",
              "format": "time_series",
              "hide": false,
              "intervalFactor": 1,
              "legendFormat": "Total Time",
              "refId": "A"
            },
            {
              "expr": "delta(pagespeed_lighthouse_first_contentful_paint_duration_seconds{env=\"ops\", host=\"$host\",path=\"$path\",strategy=\"$strategy\"}[$diff])",
              "format": "time_series",
              "intervalFactor": 1,
              "legendFormat": "First Contentful Paint",
              "refId": "B"
            },
            {
              "expr": "delta(pagespeed_lighthouse_first_cpu_idle_duration_seconds{env=\"ops\", host=\"$host\",path=\"$path\",strategy=\"$strategy\"}[$diff])",
              "format": "time_series",
              "intervalFactor": 1,
              "legendFormat": "First CPU Idle",
              "refId": "C"
            },
            {
              "expr": "delta(pagespeed_lighthouse_first_meaningful_paint_duration_seconds{env=\"ops\", host=\"$host\",path=\"$path\",strategy=\"$strategy\"}[$diff])",
              "format": "time_series",
              "intervalFactor": 1,
              "legendFormat": "First Meaningful Paint",
              "refId": "D"
            },
            {
              "expr": "delta(pagespeed_lighthouse_interactive_duration_seconds{env=\"ops\", host=\"$host\",path=\"$path\",strategy=\"$strategy\"}[$diff])",
              "format": "time_series",
              "intervalFactor": 1,
              "legendFormat": "Interactive",
              "refId": "E"
            },
            {
              "expr": "delta(pagespeed_lighthouse_speed_index_duration_seconds{env=\"ops\", host=\"$host\",path=\"$path\",strategy=\"$strategy\"}[$diff])",
              "format": "time_series",
              "intervalFactor": 1,
              "legendFormat": "Content Speed Index ",
              "refId": "F"
            },
            {
              "expr": "delta(pagespeed_lighthouse_bootup_time_duration_seconds{env=\"ops\", host=\"$host\",path=\"$path\",strategy=\"$strategy\"}[$diff])",
              "format": "time_series",
              "intervalFactor": 1,
              "legendFormat": "JS Bootup Time",
              "refId": "G"
            }
          ],
          "thresholds": [],
          "timeFrom": null,
          "timeShift": null,
          "title": "Timing Diff $diff",
          "tooltip": {
            "shared": true,
            "sort": 0,
            "value_type": "individual"
          },
          "type": "graph",
          "xaxis": {
            "buckets": null,
            "mode": "time",
            "name": null,
            "show": true,
            "values": []
          },
          "yaxes": [
            {
              "decimals": null,
              "format": "s",
              "label": "",
              "logBase": 1,
              "max": null,
              "min": null,
              "show": true
            },
            {
              "format": "s",
              "label": "",
              "logBase": 1,
              "max": null,
              "min": null,
              "show": true
            }
          ],
          "yaxis": {
            "align": false,
            "alignLevel": 0
          }
        },
        {
          "aliasColors": {},
          "bars": false,
          "dashLength": 10,
          "dashes": false,
          "datasource": "Global",
          "description": "https://developers.google.com/web/tools/lighthouse/v3/scoring",
          "fill": 1,
          "gridPos": {
            "h": 8,
            "w": 12,
            "x": 0,
            "y": 19
          },
          "id": 77,
          "legend": {
            "alignAsTable": true,
            "avg": false,
            "current": true,
            "max": false,
            "min": false,
            "rightSide": true,
            "show": true,
            "total": false,
            "values": true
          },
          "lines": true,
          "linewidth": 1,
          "links": [],
          "maxPerRow": 4,
          "nullPointMode": "null as zero",
          "percentage": false,
          "pointradius": 5,
          "points": false,
          "renderer": "flot",
          "repeat": null,
          "repeatDirection": "h",
          "repeatIteration": 1596721822575,
          "repeatPanelId": 55,
          "repeatedByRow": true,
          "scopedVars": {
            "strategy": {
              "selected": false,
              "text": "mobile",
              "value": "mobile"
            }
          },
          "seriesOverrides": [
            {
              "alias": "MAX",
              "fill": 0,
              "linewidth": 5,
              "stack": "B"
            }
          ],
          "spaceLength": 10,
          "stack": true,
          "steppedLine": false,
          "targets": [
            {
              "expr": "pagespeed_lighthouse_audit_score{env=\"ops\", host=\"$host\",path=\"$path\",strategy=\"$strategy\"}",
              "format": "time_series",
              "intervalFactor": 1,
              "legendFormat": "{{audit}}",
              "refId": "A"
            },
            {
              "expr": "count(pagespeed_lighthouse_audit_score{env=\"ops\", host=\"$host\",path=\"$path\",strategy=\"$strategy\"})",
              "format": "time_series",
              "hide": true,
              "intervalFactor": 1,
              "legendFormat": "MAX",
              "refId": "B"
            }
          ],
          "thresholds": [],
          "timeFrom": null,
          "timeShift": null,
          "title": "Audit Scores",
          "tooltip": {
            "shared": true,
            "sort": 0,
            "value_type": "individual"
          },
          "type": "graph",
          "xaxis": {
            "buckets": null,
            "mode": "time",
            "name": null,
            "show": true,
            "values": []
          },
          "yaxes": [
            {
              "decimals": 2,
              "format": "short",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": "0",
              "show": true
            },
            {
              "format": "short",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": "0",
              "show": true
            }
          ],
          "yaxis": {
            "align": false,
            "alignLevel": null
          }
        },
        {
          "aliasColors": {},
          "bars": false,
          "dashLength": 10,
          "dashes": false,
          "datasource": "Global",
          "description": "https://developers.google.com/web/tools/lighthouse/v3/scoring",
          "fill": 1,
          "gridPos": {
            "h": 8,
            "w": 12,
            "x": 12,
            "y": 19
          },
          "id": 78,
          "legend": {
            "alignAsTable": true,
            "avg": true,
            "current": true,
            "max": false,
            "min": false,
            "rightSide": true,
            "show": true,
            "sideWidth": 400,
            "total": false,
            "values": true
          },
          "lines": true,
          "linewidth": 1,
          "links": [],
          "maxPerRow": 4,
          "nullPointMode": "null as zero",
          "percentage": false,
          "pointradius": 5,
          "points": false,
          "renderer": "flot",
          "repeatDirection": "h",
          "repeatIteration": 1596721822575,
          "repeatPanelId": 63,
          "repeatedByRow": true,
          "scopedVars": {
            "strategy": {
              "selected": false,
              "text": "mobile",
              "value": "mobile"
            }
          },
          "seriesOverrides": [
            {
              "alias": "MAX",
              "fill": 0,
              "linewidth": 5,
              "stack": "B"
            }
          ],
          "spaceLength": 10,
          "stack": true,
          "steppedLine": false,
          "targets": [
            {
              "expr": "delta(pagespeed_lighthouse_audit_score{env=\"ops\", host=\"$host\",path=\"$path\",strategy=\"$strategy\"}[$diff])",
              "format": "time_series",
              "intervalFactor": 1,
              "legendFormat": "{{audit}}",
              "refId": "A"
            }
          ],
          "thresholds": [],
          "timeFrom": null,
          "timeShift": null,
          "title": "Audit Diff $diff",
          "tooltip": {
            "shared": true,
            "sort": 0,
            "value_type": "individual"
          },
          "type": "graph",
          "xaxis": {
            "buckets": null,
            "mode": "time",
            "name": null,
            "show": true,
            "values": []
          },
          "yaxes": [
            {
              "decimals": 2,
              "format": "short",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": null,
              "show": true
            },
            {
              "format": "short",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": null,
              "show": true
            }
          ],
          "yaxis": {
            "align": false,
            "alignLevel": null
          }
        },
        {
          "aliasColors": {},
          "bars": false,
          "dashLength": 10,
          "dashes": false,
          "datasource": "Global",
          "fill": 1,
          "gridPos": {
            "h": 8,
            "w": 12,
            "x": 0,
            "y": 27
          },
          "id": 79,
          "legend": {
            "alignAsTable": true,
            "avg": true,
            "current": true,
            "max": true,
            "min": true,
            "rightSide": true,
            "show": true,
            "total": false,
            "values": true
          },
          "lines": true,
          "linewidth": 1,
          "links": [],
          "nullPointMode": "null",
          "percentage": false,
          "pointradius": 5,
          "points": false,
          "renderer": "flot",
          "repeatIteration": 1596721822575,
          "repeatPanelId": 57,
          "repeatedByRow": true,
          "scopedVars": {
            "strategy": {
              "selected": false,
              "text": "mobile",
              "value": "mobile"
            }
          },
          "seriesOverrides": [],
          "spaceLength": 10,
          "stack": false,
          "steppedLine": false,
          "targets": [
            {
              "expr": "pagespeed_lighthouse_category_score{env=\"ops\", host=\"$host\",path=\"$path\",strategy=\"$strategy\"}*100 ",
              "format": "time_series",
              "intervalFactor": 1,
              "legendFormat": "{{category}}",
              "refId": "A"
            }
          ],
          "thresholds": [],
          "timeFrom": null,
          "timeShift": null,
          "title": "Score History",
          "tooltip": {
            "shared": true,
            "sort": 0,
            "value_type": "individual"
          },
          "type": "graph",
          "xaxis": {
            "buckets": null,
            "mode": "time",
            "name": null,
            "show": true,
            "values": []
          },
          "yaxes": [
            {
              "decimals": 2,
              "format": "percent",
              "label": null,
              "logBase": 1,
              "max": "100",
              "min": "0",
              "show": true
            },
            {
              "decimals": 2,
              "format": "short",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": null,
              "show": true
            }
          ],
          "yaxis": {
            "align": false,
            "alignLevel": null
          }
        },
        {
          "aliasColors": {},
          "bars": false,
          "dashLength": 10,
          "dashes": false,
          "datasource": "Global",
          "decimals": 2,
          "fill": 1,
          "gridPos": {
            "h": 8,
            "w": 12,
            "x": 12,
            "y": 27
          },
          "id": 80,
          "legend": {
            "alignAsTable": true,
            "avg": true,
            "current": true,
            "max": false,
            "min": false,
            "rightSide": true,
            "show": true,
            "sideWidth": 400,
            "total": false,
            "values": true
          },
          "lines": true,
          "linewidth": 1,
          "links": [],
          "nullPointMode": "null",
          "percentage": false,
          "pointradius": 5,
          "points": false,
          "renderer": "flot",
          "repeatIteration": 1596721822575,
          "repeatPanelId": 64,
          "repeatedByRow": true,
          "scopedVars": {
            "strategy": {
              "selected": false,
              "text": "mobile",
              "value": "mobile"
            }
          },
          "seriesOverrides": [],
          "spaceLength": 10,
          "stack": false,
          "steppedLine": false,
          "targets": [
            {
              "expr": "delta(pagespeed_lighthouse_category_score{env=\"ops\", host=\"$host\",path=\"$path\",strategy=\"$strategy\"}[$diff])*100",
              "format": "time_series",
              "intervalFactor": 1,
              "legendFormat": "{{category}}",
              "refId": "A"
            }
          ],
          "thresholds": [],
          "timeFrom": null,
          "timeShift": null,
          "title": "Score History Diff $diff",
          "tooltip": {
            "shared": true,
            "sort": 0,
            "value_type": "individual"
          },
          "type": "graph",
          "xaxis": {
            "buckets": null,
            "mode": "time",
            "name": null,
            "show": true,
            "values": []
          },
          "yaxes": [
            {
              "decimals": null,
              "format": "percent",
              "label": null,
              "logBase": 1,
              "max": "100",
              "min": "-100",
              "show": true
            },
            {
              "decimals": null,
              "format": "short",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": null,
              "show": true
            }
          ],
          "yaxis": {
            "align": false,
            "alignLevel": null
          }
        }
      ],
      "repeat": null,
      "repeatIteration": 1596721822575,
      "repeatPanelId": 66,
      "scopedVars": {
        "strategy": {
          "selected": false,
          "text": "mobile",
          "value": "mobile"
        }
      },
      "title": "Timings / Scores / Audits ($strategy)",
      "type": "row"
    },
    {
      "collapsed": true,
      "datasource": null,
      "gridPos": {
        "h": 1,
        "w": 24,
        "x": 0,
        "y": 12
      },
      "id": 4,
      "panels": [
        {
          "aliasColors": {},
          "bars": false,
          "dashLength": 10,
          "dashes": false,
          "datasource": "Global",
          "fill": 1,
          "gridPos": {
            "h": 9,
            "w": 24,
            "x": 0,
            "y": 7
          },
          "id": 2,
          "legend": {
            "alignAsTable": true,
            "avg": true,
            "current": false,
            "max": true,
            "min": true,
            "rightSide": false,
            "show": true,
            "total": false,
            "values": true
          },
          "lines": true,
          "linewidth": 1,
          "links": [],
          "nullPointMode": "connected",
          "percentage": false,
          "pointradius": 5,
          "points": false,
          "renderer": "flot",
          "seriesOverrides": [],
          "spaceLength": 10,
          "stack": false,
          "steppedLine": false,
          "targets": [
            {
              "expr": "pagespeed_scrape_duration_seconds",
              "format": "time_series",
              "intervalFactor": 1,
              "legendFormat": "scrape duration",
              "refId": "A"
            }
          ],
          "thresholds": [],
          "timeFrom": null,
          "timeShift": null,
          "title": "Pagespeed Scrape Duration",
          "tooltip": {
            "shared": true,
            "sort": 0,
            "value_type": "individual"
          },
          "type": "graph",
          "xaxis": {
            "buckets": null,
            "mode": "time",
            "name": null,
            "show": true,
            "values": []
          },
          "yaxes": [
            {
              "format": "s",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": "0",
              "show": true
            },
            {
              "format": "short",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": null,
              "show": true
            }
          ],
          "yaxis": {
            "align": false,
            "alignLevel": null
          }
        }
      ],
      "title": "Pagespeed Exporter Metrics",
      "type": "row"
    }
  ],
  "refresh": false,
  "schemaVersion": 25,
  "style": "dark",
  "tags": [],
  "templating": {
    "list": [
      {
        "allValue": null,
        "current": {
          "selected": false,
          "text": "https://gitlab.com",
          "value": "https://gitlab.com"
        },
        "datasource": "Global",
        "definition": "",
        "hide": 0,
        "includeAll": false,
        "label": "host",
        "multi": false,
        "name": "host",
        "options": [],
        "query": "label_values(pagespeed_lighthouse_category_score,host)",
        "refresh": 1,
        "regex": "",
        "skipUrlSync": false,
        "sort": 6,
        "tagValuesQuery": "",
        "tags": [],
        "tagsQuery": "",
        "type": "query",
        "useTags": false
      },
      {
        "allValue": null,
        "current": {
          "selected": false,
          "text": "/gitlab-org/gitlab",
          "value": "/gitlab-org/gitlab"
        },
        "datasource": "Global",
        "definition": "",
        "hide": 0,
        "includeAll": false,
        "label": "path",
        "multi": false,
        "name": "path",
        "options": [],
        "query": "label_values(pagespeed_lighthouse_category_score{env=\"ops\", host=\"$host\"},path)",
        "refresh": 1,
        "regex": "",
        "skipUrlSync": false,
        "sort": 6,
        "tagValuesQuery": "",
        "tags": [],
        "tagsQuery": "",
        "type": "query",
        "useTags": false
      },
      {
        "allValue": "all",
        "current": {
          "selected": false,
          "text": "All",
          "value": "$__all"
        },
        "datasource": "Global",
        "definition": "",
        "hide": 0,
        "includeAll": true,
        "label": "strategy",
        "multi": true,
        "name": "strategy",
        "options": [],
        "query": "label_values(pagespeed_lighthouse_category_score,strategy)",
        "refresh": 1,
        "regex": "",
        "skipUrlSync": false,
        "sort": 0,
        "tagValuesQuery": "",
        "tags": [],
        "tagsQuery": "",
        "type": "query",
        "useTags": false
      },
      {
        "allValue": null,
        "current": {
          "selected": true,
          "text": "1w",
          "value": "1w"
        },
        "hide": 0,
        "includeAll": false,
        "label": "Diff",
        "multi": false,
        "name": "diff",
        "options": [
          {
            "selected": false,
            "text": "1d",
            "value": "1d"
          },
          {
            "selected": false,
            "text": "2d",
            "value": "2d"
          },
          {
            "selected": true,
            "text": "1w",
            "value": "1w"
          },
          {
            "selected": false,
            "text": "2w",
            "value": "2w"
          },
          {
            "selected": false,
            "text": "1m",
            "value": "1m"
          }
        ],
        "query": "1d,2d,1w, 2w, 1m",
        "skipUrlSync": false,
        "type": "custom"
      }
    ]
  },
  "time": {
    "from": "now-1h",
    "to": "now"
  },
  "timepicker": {
    "refresh_intervals": [
      "5s",
      "10s",
      "30s",
      "1m",
      "5m",
      "15m",
      "30m",
      "1h",
      "2h",
      "1d"
    ],
    "time_options": [
      "5m",
      "15m",
      "1h",
      "6h",
      "12h",
      "24h",
      "2d",
      "7d",
      "30d"
    ]
  },
  "timezone": "",
  "title": "Pagespeed",
  "version": 1
}
