require('tabby.tabline').set(function(line)
  return {
    line.tabs().foreach(function(tab)
      return {
        line.tab_label(tab),
        hl = tab.is_current() and 'TabLineSel' or 'TabLine',
      }
    end),
    hl = 'TabLineFill',
  }
end)

