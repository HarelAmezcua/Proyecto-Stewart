v = videoinput("winvideo", 1, "YUY2_640x360");
start(v);
for k=1:10
snapshot1 = getsnapshot(v);
snapshot2=(ycbcr2rgb(snapshot1));
snapshot2=im2double(snapshot2);
snapshot2=255-snapshot2;
figure(1);
imshow(snapshot2)
drawnow;
end
stop(v);
[x,y]=find(busqueda==1);
cx=sum(x)/length(x);
cy=sum(y)/length(y);
hold on;
plot(cy,cx,"ro")