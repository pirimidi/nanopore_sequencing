%--------------------------------------------------------------------------
% Author: Mirko Palla, PhD.
% Date: February 9, 2016.
%
% For: Single molecule DNA sequencing via aHL nanopore array at the Church
% Lab - Genetics Department, Harvard Medical School.
%
% Purpose: Given a text file containing alignment statistics (generated by 
% 'get_reads.m'), this program iterates through all lines and generates a 
% data structure holding each alignment object with fields:
%
% - identity = % identity of alignment 
% - cell_id = single trace ID number 
% - template = DNA template to be matched to (JAMA)
% - match = matching symbols {:, , |}
% - read = nanopore read based on electronic signal 
% - length = readlength using local alignment
%
% The default thresholds are for alignment length = AL > 10, percent 
% identity = PI > 60 and T base match = TM > 2. 
%
% This software may be used, modified, and distributed freely, but this
% header may not be modified and must appear at the top of this file.
%--------------------------------------------------------------------------

function alignment_objects(filename, AL, PI, TM)

%-------------------------------------------------------------------------%
%                                 STARTUP                                 %
%-------------------------------------------------------------------------%

fprintf('\n');
disp('--> Alignment objects start');

% Set default number formatting.
format short;

% Turn off warnings during run.
warning('off', 'all');

% Define current working directory.
work_dir = pwd;

%-------------------------------------------------------------------------%
%                           DATA EXTRACTION SECTION                       %
%-------------------------------------------------------------------------%

disp('--> DATA EXTRACTION SECTION');

% Import text file into a matrix.
A = importdata('lumped_single-pass_output.txt');

% Line stems and iteration constant.
identity = 2;
cell_id = 3;
template = 7;
match = 8;
read = 9;
iter = 10;

% Iterate through every line.
for i = 1:floor(length(A)/10)
  
    %disp(['--> Processing line: ', num2str(i)]);  
    
    % Initialize N/T counter.
    n_count = 0;
    t_count = 0;
    
    % Parse out percent identity value.
    a = char(A(identity + iter*(i-1)));
    alignment(i).identity = str2num(a(15:16));

    % Parse out cell id value.
    b = char(A(cell_id + iter*(i-1)));
    
    if length(b) == 27
        alignment(i).cell_id = cellstr(b(14:27));
    else 
        alignment(i).cell_id = cellstr(b(14:26));
    end
    
    % Parse out template character array.
    c = char(A(template + iter*(i-1)));
    alignment(i).template = c;
    
    % Parse out match character array.
    d = char(A(match + iter*(i-1)));
    alignment(i).match = d;
    
    % Parse out nanopore read character array.
    e = char(A(read + iter*(i-1)));
    alignment(i).read = e;
    
    % Compute readlength (of alignment).
    alignment(i).length = length(char(A(template + iter*(i-1))));
    
    % Compute numer of exact matches.
    for j = 1:length(c)
        if strcmp(c(j), e(j))
            n_count = n_count + 1;
            
            % Compute T macthes only.
            if strcmp(c(j), 'T')
                t_count = t_count + 1;
            end
        end
    end
       
    alignment(i).n_count = n_count;
    alignment(i).t_count = t_count;

end    

% Insert spacer row.
fprintf('\n');

%-------------------------------------------------------------------------%
%                          SORT BY FIELD VALUE                            %
%-------------------------------------------------------------------------%

% Sort contructed alignment objects by descending alignment length (AL), 
% percent identity (PI) and T base match (TM). The default thresholds are:
% AL > 10, PI > 70%, TM > 2. We may further hand sort (T issue) to select 
% "good" subset. 
C = nestedSortStruct(alignment, 'identity');

k=1;
for id = 1:length(C)
    if (C(id).length > AL && C(id).t_count > TM && C(id).identity > PI)        
        % Print filtered alignment object.
        fprintf('--> %d alignment object, index #%d\n', k, id)
        C(id)
        k=k+1;        
    end
end

%-------------------------------------------------------------------------%
%                            FINISHING TASK                               %
%-------------------------------------------------------------------------%

% Navigate to working directory.
cd(work_dir);

disp('--> Alignment objects end');
fprintf('\n');