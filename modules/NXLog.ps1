$conf += '
<Input nxlog>
  Module im_internal
  Exec $EventReceivedTime = integer($EventReceivedTime) / 1000000;
  Exec $NXLogHostname = '
  $conf += "'"
  $conf += $env:computername
  $conf += "';"
  $conf += '
  Exec to_json();
</Input>

<Route nxlog>
  Path nxlog => collector
</Route>
'