import "../theme"
import "../services"

UsagePill {
  icon: Icons.disk
  value: SystemUsage.disk
  tooltipText: `Disk ${SystemUsage.diskUsedGb.toFixed(0)} / ${SystemUsage.diskTotalGb.toFixed(0)} GiB`
}
