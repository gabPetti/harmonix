import "../theme"
import "../services"

UsagePill {
  icon: Icons.ram
  value: SystemUsage.memory
  tooltipText: `RAM ${SystemUsage.memoryUsedGb.toFixed(1)} / ${SystemUsage.memoryTotalGb.toFixed(1)} GiB`
}
