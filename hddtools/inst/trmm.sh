echo '<VRTDataset rasterXSize="1440" rasterYSize="400"> 
 <Geotransform>-180,0.25,0,50, 0, -0.25</Geotransform> 
 <SRS>WGS84</SRS>' >TRMM.vrt;
for i in 3B43.12*
do echo '<VRTRasterBand dataType="Float32" band="1" subClass="VRTRawRasterBand"> 
 <SourceFilename relativeToVRT="1">'$i'</SourceFilename> 
 <ByteOrder>MSB</ByteOrder>
 <ImageOffset>0</ImageOffset>
 <PixelOffset>4</PixelOffset>
 <LineOffset>5760</LineOffset>
 </VRTRasterBand>' >>TRMM.vrt
done;
echo '</VRTDataset>' >>TRMM.vrt