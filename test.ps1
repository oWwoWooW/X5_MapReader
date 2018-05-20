$a = 'F:\882556254_981_1.4.4.0_20180516114358_apkupdate\assets\assetbundles\audio\bgm';
$b = dir $a -Recurse | select fullname;
for($i = 0; $i -lt $b.Count; $i++)
{
    $regexp = [regex]'-\d+\d+-[\d.]+';
    $a = $b[$i].FullName;
    # $aa = $regexp.Matches($a)[0].Value
    $p = $a -replace 'acc', 'aac'
    # $p = $a + '.ZIP';
    Rename-Item $a $p;
  #  python C:\Users\0\OneDrive\X5_Bytes2Xml\Read_Origin_Xml_PinBall.py $b[$i].FullName;
}