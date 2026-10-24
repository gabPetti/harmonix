import "../theme"
import "../services"

UsagePill {
  icon: Icons.cpu
  value: SystemUsage.cpu
  tooltipText: `CPU ${Math.round(SystemUsage.cpu)}%`
}
