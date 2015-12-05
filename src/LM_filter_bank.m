function LM_filter_bank()
    %Get the 48 filters for the LM filter bank.
    F = makeLMfilters();
    %disp_filters(F);
    disp('Got filters')
    modified_images = modify_images(0);
    [total_images,img_x,img_y,~] = size(modified_images);
    
    %TODO: Remove
    total_images = 1;
    
    gray_modified_images = zeros(total_images, img_x, img_y);
    %Convert the modified images to grayscale for LM filter bank to work.
    for i=1:total_images
        gray_modified_images(i,:,:) = rgb2gray(squeeze(modified_images(i,:,:,:)));
    end
    %imshow(squeeze(gray_modified_images(1,:,:)));
    disp('Converted Modified RGB Images to Grayscale')
    
    conv_x_dim = 904;
    conv_y_dim = 1042;
    response = zeros(total_images,conv_x_dim, conv_y_dim,48);
    %Get the response of each filter for each image.
    total_filters = 48;
    for i=1:total_images
        curr_img = squeeze(gray_modified_images(i,:,:));
        for j=1:total_filters
            response(i,:,:,j) = conv2(curr_img,F(:,:,j), 'valid');
        end
    end
    disp('Got the reponse of each filter for each image')
    size(response)
    %Display all the filter's responses for an image.
    first_img_response = squeeze(response(1,:,:,:));
    %disp_response(first_img_response,1,1);
    for i=1:4:48
        disp_response(first_img_response,i,i + 3);
    end

  
function disp_response(first_img_response, start_id, end_id)
    str_start = strcat(int2str(start_id), ' To ');
    str_range = strcat(str_start, int2str(end_id));
    str_fig_name = strcat('Image 1 Filter: ', str_range);
    figure('Name', str_fig_name);
    for filter_num=start_id:end_id
        subplot(1,12,filter_num - start_id + 1);
        imagesc(squeeze(first_img_response(:,:,filter_num)));
        colormap(gray);
    end

function disp_filters(F)
    for i=1:48
        subplot(4,12,i);
        imagesc(squeeze(F(:,:,i)));
        colormap(gray);
    end
   
function F=makeLMfilters()
% Returns the LML filter bank of size 49x49x48 in F. To convolve an
% image I with the filter bank you can either use the matlab function
% conv2, i.e. responses(:,:,i)=conv2(I,F(:,:,i),'valid'), or use the
% Fourier transform.

  SUP=49;                 % Support of the largest filter (must be odd)
  SCALEX=sqrt(2).^[1:3];  % Sigma_{x} for the oriented filters
  NORIENT=6;              % Number of orientations

  NROTINV=12;
  NBAR=length(SCALEX)*NORIENT;
  NEDGE=length(SCALEX)*NORIENT;
  NF=NBAR+NEDGE+NROTINV;
  F=zeros(SUP,SUP,NF);
  hsup=(SUP-1)/2;
  [x,y]=meshgrid([-hsup:hsup],[hsup:-1:-hsup]);
  orgpts=[x(:) y(:)]';

  count=1;
  for scale=1:length(SCALEX),
    for orient=0:NORIENT-1,
      angle=pi*orient/NORIENT;  % Not 2pi as filters have symmetry
      c=cos(angle);s=sin(angle);
      rotpts=[c -s;s c]*orgpts;
      F(:,:,count)=makefilter(SCALEX(scale),0,1,rotpts,SUP);
      F(:,:,count+NEDGE)=makefilter(SCALEX(scale),0,2,rotpts,SUP);
      count=count+1;
    end;
  end;
  
  count=NBAR+NEDGE+1;
  SCALES=sqrt(2).^[1:4];
  for i=1:length(SCALES),
    F(:,:,count)=normalise(fspecial('gaussian',SUP,SCALES(i)));
    F(:,:,count+1)=normalise(fspecial('log',SUP,SCALES(i)));
    F(:,:,count+2)=normalise(fspecial('log',SUP,3*SCALES(i)));
    count=count+3;
  end;
return

function f=makefilter(scale,phasex,phasey,pts,sup)
  gx=gauss1d(3*scale,0,pts(1,:),phasex);
  gy=gauss1d(scale,0,pts(2,:),phasey);
  f=normalise(reshape(gx.*gy,sup,sup));
return

function g=gauss1d(sigma,mean,x,ord)
% Function to compute gaussian derivatives of order 0 <= ord < 3
% evaluated at x.

  x=x-mean;num=x.*x;
  variance=sigma^2;
  denom=2*variance;  
  g=exp(-num/denom)/(pi*denom)^0.5;
  switch ord,
    case 1, g=-g.*(x/variance);
    case 2, g=g.*((num-variance)/(variance^2));
  end;
return

function f=normalise(f), f=f-mean(f(:)); f=f/sum(abs(f(:))); return