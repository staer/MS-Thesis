function WriteBB2File(frame, x, y, width, height)
% Write the bounding box info to a text file for further processing by 
% another system.

f = fopen('BoundingBoxOutput.txt','a');

frame = strcat('Frame: ',num2str(frame),'\n');
fprintf(f,frame);
frame = strcat('X: ',num2str(x),'\n');
fprintf(f,frame);
frame = strcat('Y: ',num2str(y),'\n');
fprintf(f,frame);
frame = strcat('W: ',num2str(width),'\n');
fprintf(f,frame);
frame = strcat('H: ',num2str(height),'\n');
fprintf(f,frame);

fclose(f);