clear;
image_path = 'C:/Users/Hancy/Desktop/Total-Text-Dataset-master/images'; %image directory
out_path = 'C:/Users/Hancy/Desktop/Total-Text-Dataset-master/annotation'; %save directory
type_names = {'Flake off','Injured fastener','Puncture Perforation','Fastener hole','Dent','Crack','Scratch','Corrosion','Lightening strike'};

allFiles = dir(image_path);
allNames = { allFiles.name };

start = input('开始图像编号#');
noOfImages = input('本次标注图像数量#');
start = start + 2;
finish = start + (noOfImages-1);
for j = start:finish
    allNames{j};
    %load an image
    disp = imread([image_path '/' allNames{j}]);
    close('all');
    imshow(disp);

    polygt = [];
    polygt_ori = [];
    
    gt_name = strsplit(allNames{j}, '.');
    file_name=strcat('/Polygon/poly_gt_',gt_name(1),'.txt');
    GT_savepath = fullfile(out_path,file_name);
    %GT_savepath = strcat(out_path, '/Polygon/poly_gt_', gt_name(1), '.txt');
    GT_savepath = GT_savepath{1};

    fid2 = fopen(GT_savepath,'r');
    C = textscan(fid2,'%s%d%d%d%d%d%d%d%d');
    lines = size(C{1,1},1);
    oposT = cell(2*lines,4);
    for c1 = 1:size(oposT,1)
        for c2 = 1:size(oposT,2)
            if mod(c1,2) == 0
                oposT(c1,c2) = {C{1,2*c2+1}(ceil(c1/2),1)};
                type_ind(ceil(c1/2)) = C{1,1}(ceil(c1/2),1);
            else
                oposT(c1,c2) = {C{1,2*c2}(ceil(c1/2),1)};
            end
        end
    end
    
    oposT = cell2mat(oposT);

    for l = 1:lines
        poly_output = { 'x:', oposT(2*l-1,:), 'y:',oposT(2*l,:),type_ind(l)};
        type_index = int16(char(type_ind(1,1))) - 48;
        polygt_ori = [polygt_ori ; poly_output];
        % text(double(oposT(2*l-1,1)),double(oposT(2*l,1)),char(type_names(type_index)),'horiz','center','color','r') 
        Line = sprintf('Line: %d ',l);
        text(double(oposT(2*l-1,1)),double(oposT(2*l,1)),strcat(Line,char(type_names(type_index))),'color','r') 
    end
    disp_poly(polygt_ori);
 
    %prompt for number of groundtruth
    n = input('本张图像共有几个待标注目标？');
    count = n; %to keep track of how many ground-truths left to be annotated

    fid = fopen(GT_savepath,'a+');

    % fid = fopen(GT_savepath,'w+');

    %Poly GT
    i = 1;
    while i <= n
        fprintf('%d',i)
        %%%根据输入目标数画多边形
        h = impoly(gca);
        pos = getPosition(h);
        pos = int16(pos);
        posT = pos.';
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %total_types = size(type_names,2)
        for num_type= 1:size(type_names,2)
            fprintf('#%d:%s ',num_type, char(type_names(num_type)));
        end
        type = input('\n请输入类别编号','s'); %transcription annotation

        fprintf('Annotated Info:\n');
        fprintf('------------------------------------------------------\n');
        fprintf('# %d | type_name : %s \n x1: %3d y1: %3d x2: %3d y2: %3d \n x3: %3d y3: %3d x4: %3d y4: %3d\n', str2num(type) ,char(type_names(str2num(type))),posT(1,1),posT(2,1),posT(1,2),posT(2,2),posT(1,3),posT(2,3),posT(1,4),posT(2,4));
        fprintf('------------------------------------------------------\n');
        choice_of_modify = input('本次标定是否正确:y/n','s');
        if(choice_of_modify == 'n')
            set(h,'Visible','off');
            fprintf('重新标定\n');
            fprintf('还剩 %d 个伤痕需要标注 \n',n-i+1);
            continue;
        elseif(choice_of_modify == 'y')
            
            i = i + 1 ;
            poly_output = { 'x:', posT(1,:), 'y:', posT(2,:), type};
            polygt = [polygt ; poly_output];
            % count = count - 1 %counter update
            text(double(posT(1,1)),double(posT(1,2)),char(type_names(str2num(type))),'color','r') 
            fprintf(fid,'%s %d %d %d %d %d %d %d %d\n',type,posT(1,1),posT(2,1),posT(1,2),posT(2,2),posT(1,3),posT(2,3),posT(1,4),posT(2,4));
            fprintf('结果已保存\n');
            fprintf('还剩 %d 个伤痕需要标注 \n',n-i+1);
        else
            fprintf('输入错误，退出\n');
            break;
        end
    end
    fclose(fid);
    % save(GT_savepath{1},'polygt');

    imshow(disp);
    disp_poly(polygt);
    dummy = input('按任意键结束本张图像标定', 's');
    close('all');
end
