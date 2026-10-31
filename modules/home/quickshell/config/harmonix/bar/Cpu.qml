import "../theme"
import "../services"

UsagePill {
  icon: Icons.cpuSymbol
  symbol: true
  value: SystemUsage.cpu
  tooltipText: `CPU ${Math.round(SystemUsage.cpu)}%`
}
