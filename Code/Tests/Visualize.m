%RFvisualization

%imData = CreateGDFilter(41,1,0,0,0,0,0,45,1.0,1.0,1.0,1/(sqrt(2*pi)));


%imData = CreateGDFilter(41,1,0,0,0,0,90,90,1.0,1.0,1.0,1/(sqrt(2*pi)));

imData = CreateGDFilter(41,1,0,0,0,0,0,45,1.0,1.0,1.0,1/(sqrt(2*pi)));

[x,y,z] = meshgrid(-2:.1:2, -2:.1:2, -2:.1:2);
v = imData;
figure,
p = patch(isosurface(x, y, z, v, .3)); %.5 value
isonormals(x,y,z,v, p)
      set(p, 'FaceColor', 'red', 'EdgeColor', 'none');
      daspect([1 1 1])
      view(3)
      camlight; lighting phong

 %figure,
 hold on
 p = patch(isosurface(x, y, z, v, -.3));  %-.5 value
isonormals(x,y,z,v, p)
      set(p, 'FaceColor', 'blue', 'EdgeColor', 'none');
      daspect([1 1 1])
      view(3)
      camlight; lighting phong
xlabel('x')
ylabel('y')
zlabel('t')