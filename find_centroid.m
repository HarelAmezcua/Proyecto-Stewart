v = videoinput("winvideo", 1, "YUY2_640x360");
start(v);
snapshot1 = getsnapshot(v);
stop(v);
snapshot2=rgb2gray(ycbcr2rgb(snapshot1));
busqueda=snapshot2<50;
imshow(busqueda)
[x,y]=find(busqueda==1);
cx=sum(x)/length(x);
cy=sum(y)/length(y);
hold on;
plot(cy,cx,"ro")