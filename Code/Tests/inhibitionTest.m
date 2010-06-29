img = mat2gray(imread('colordifferencemap.bmp'));
figure, imshow(img), title('original');

img = Inhibit(img);

figure, imshow(img), title('inhibited');