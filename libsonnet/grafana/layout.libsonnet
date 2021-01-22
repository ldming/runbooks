local grafana = import 'github.com/grafana/grafonnet-lib/grafonnet/grafana.libsonnet';

local generateColumnOffsets(columnWidths) =
  std.foldl(function(columnOffsets, width) columnOffsets + [width + columnOffsets[std.length(columnOffsets) - 1]], columnWidths, [0]);

local generateRowOffsets(cellHeights) =
  std.foldl(function(rowOffsets, cellHeight) rowOffsets + [cellHeight + rowOffsets[std.length(rowOffsets) - 1]], cellHeights, [0]);

local generateDropOffsets(cellHeights, rowOffsets) =
  local totalHeight = std.foldl(function(sum, cellHeight) sum + cellHeight, cellHeights, 0);
  [
    totalHeight - rowOffset
    for rowOffset in rowOffsets
  ];


{
  // Returns a grid layout with `cols` columns
  // panels should be an array of panels
  grid(panels, cols=2, rowHeight=10, startRow=0)::
    std.mapWithIndex(
      function(index, panel)
        panel {
          gridPos: {
            x: ((24 / cols) * index) % 24,
            y: std.floor(((24 / cols) * index) / 24) * rowHeight + startRow,
            w: 24 / cols,
            h: rowHeight,
          },
        },
      panels
    ),

  // Layout all the panels in a single row
  singleRow(panels, rowHeight=10, startRow=0)::
    local cols = std.length(panels);
    self.grid(panels, cols=cols, rowHeight=rowHeight, startRow=startRow),

  // Layout all panels in a single row, with a title row
  // rowGrid method adds the panels as consecutive panels. It makes collapse
  // option doesn't work on child panels of a row. A panel should be a child of
  // a row.
  rowGrid(rowTitle, panels, startRow)::
    [
      grafana.row.new(title=rowTitle) { gridPos: { x: 0, y: startRow, w: 24, h: 1 } },
    ] + self.singleRow(panels, startRow=(startRow + 1)),

  // Rows -> array of arrays. Each outer array is a row.
  rows(rowsOfPanels, rowHeight=10, startRow=0)::
    std.flattenArrays(
      std.mapWithIndex(
        function(index, panels)
          if std.isArray(panels) then
            self.singleRow(panels, rowHeight=rowHeight, startRow=index * rowHeight + startRow)
          else
            local panel = panels;
            [
              panel {
                gridPos: {
                  x: 0,
                  y: index * rowHeight + startRow,
                  w: 24,
                  h: rowHeight,
                },
              },
            ],
        rowsOfPanels
      )
    ),

  columnGrid(rowsOfPanels, columnWidths, rowHeight=10, startRow=0)::
    local columnOffsets = generateColumnOffsets(columnWidths);

    std.flattenArrays(
      std.mapWithIndex(
        function(rowIndex, rowOfPanels)
          std.mapWithIndex(
            function(colIndex, panel)
              panel {
                gridPos: {
                  x: columnOffsets[colIndex],
                  y: rowIndex * rowHeight + startRow,
                  w: columnWidths[colIndex],
                  h: rowHeight,
                },
              },
            rowOfPanels
          ),
        rowsOfPanels
      )
    ),

  // Each column contains an array of cells, stacked vertically
  // the heights of each cell are defined by cellHeights
  splitColumnGrid(columnsOfPanels, cellHeights, startRow)::
    local colWidth = std.floor(24 / std.length(columnsOfPanels));
    local rowOffsets = generateRowOffsets(cellHeights);
    local dropOffsets = generateDropOffsets(cellHeights, rowOffsets);

    std.prune(
      std.flattenArrays(
        std.mapWithIndex(
          function(colIndex, columnOfPanels)
            std.mapWithIndex(
              function(cellIndex, cell)
                if cell == null then
                  null
                else
                  local lastRowInColumn = cellIndex == (std.length(columnOfPanels) - 1);

                  // The height of the last cell will extend to the bottom
                  local height = if !lastRowInColumn then
                    cellHeights[cellIndex]
                  else
                    dropOffsets[cellIndex];

                  local gridPos = {
                    x: colWidth * colIndex,
                    y: rowOffsets[cellIndex] + startRow,
                    w: colWidth,
                    h: height,
                  };

                  cell {
                    gridPos: gridPos,
                  },
              columnOfPanels
            ),
          columnsOfPanels
        )
      )
    ),

}
