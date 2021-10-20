%Claudia Petidier 100430698
%Carlos Suárez Pardo 100429792
%Gonzalo Prats Juliani 100429904
%Isabel Diez De Rivera 100429935

%Import the data
arginfo = xlsread ('datanumerico.xlsx','A2:E113'); %Population 44780675
brainfo = xlsread ('datanumerico.xlsx','F2:J186'); %Population 211049519
perinfo = xlsread ('datanumerico.xlsx','K2:O175'); %Population 32510462
espinfo = xlsread ('datanumerico.xlsx','P2:t130'); %Population 46937060
arginfo(:, 3) = [];
brainfo(:, 3) = [];
perinfo(:, 3) = [];
espinfo(:, 3) = [];

%ARGENTINA:average between the past 7 days up to a certain given day
Asizematrix = size(arginfo);
Anumofrows = Asizematrix(1);
Aaveragematrix = arginfo;
for i=1:(Anumofrows-7)
    %Initialize the average values
    Aaveragecases = 0;
    Aaveragedeaths = 0;
    for j = i:i+7
        Aaveragecases = Aaveragecases + Aaveragematrix(j,1);
        Aaveragedeaths = Aaveragedeaths + Aaveragematrix(j,2);
    end
    Aaveragecases = Aaveragecases / 8;
    Aaveragedeaths = Aaveragedeaths / 8;
    Aaveragematrix(i,1) = Aaveragecases;
    Aaveragematrix(i,2) = Aaveragedeaths;
end

%control sample and working sample
Acontrol = Aaveragematrix(1:2:end,:);
Aworking = Aaveragematrix(2:2:end,:);

%Interpolation, create the vector
Aworkingvcases = [];
Aworkingvdeaths = [];
for m = size(Aworking):-1:1
    Aworkingvcases = [Aworkingvcases Aworking(m, 1)];
    Aworkingvdeaths = [Aworkingvdeaths Aworking(m, 2)];
end

%Repeating process without averaging:
Acontrol2 = arginfo(1:2:end,:);
Aworking2 = arginfo(2:2:end,:);

%Interpolation, create the vector
Aworking2vcases = [];
Aworking2vdeaths = [];
for m = size(Aworking2):-1:1
    Aworking2vcases = [Aworking2vcases Aworking2(m, 1)];
    Aworking2vdeaths = [Aworking2vdeaths Aworking2(m, 2)];
end

%Obtain the interpolated functions

vectx = [];
for k = 1:size(Aworking)
    vectx = [vectx k];
end
x = vectx;
y = Aworkingvcases;
g = Aworkingvdeaths;
Acscases = csapi(x, y);
Acsdeaths = csapi(x, g);
%Interpolating without averaging
x2=vectx;
y2=Aworking2vcases;
g2=Aworking2vdeaths;
%Interpolating functions
Acscases2 = csapi(x2, y2);
Acsdeaths2 = csapi(x2,g2);    

%MEASURE: Calculation of errors in Argentina
%NOT AVERAGE ERRORS
%Matrix of absolute errors by day (control day sample):
AErrorsCases = [];
AErrorsDeaths = [];
Acontrolcasesvec = [];
Acontroldeathsvec = [];

%Flip the vector so we have an increasing order
for j = size(Acontrol2, 1): -1: 1
    Acontrolcasesvec = [Acontrolcasesvec Acontrol2(j, 1)];
    Acontroldeathsvec = [Acontroldeathsvec Acontrol2(j, 2)];
end
mylin = linspace(1, size(Acontrol2, 1), size(Acontrol2, 1));
%The values for each day (cases and deaths)
Avaluescases = fnval(Acscases2, mylin);
Avaluesdeaths = fnval(Acsdeaths2, mylin);
%For each day, we evaluate what is the error between the interpolation and
%the control values
for i = 1: size(Acontrol2, 1)
    AErrorsCases = [AErrorsCases abs(Avaluescases(i) - Acontrolcasesvec(i))];
    AErrorsDeaths = [AErrorsDeaths abs(Avaluesdeaths(i) - Acontroldeathsvec(i))];
end

%Absolute total error on cases and deaths
ATotalErrorCases = 0;
AControlCases = 0;
for i=1:length(AErrorsCases)
    ATotalErrorCases = ATotalErrorCases + AErrorsCases(i);
    AControlCases = AControlCases + Acontrol2(i,1);
end
ATotalErrorDeaths = 0;
AControlDeaths = 0;
for i=1:length(AErrorsDeaths)
    ATotalErrorDeaths = ATotalErrorDeaths + AErrorsDeaths(i);
    AControlDeaths = AControlDeaths + Acontrol2(i,2);
end

%Relative total error on cases and deaths (should put in absolute value)
ARelErrorCases = ATotalErrorCases/AControlCases;
ARelErrorDeaths = ATotalErrorDeaths/AControlDeaths;


%AVERAGE ERRORS
%Matrix of absolute errors by day (control day sample):
AErrorsavgCases = [];
AErrorsavgDeaths = [];
Acontrolavgcasesvec = [];
Acontroldeathsavgvec = [];

%Flip the vector so we have an increasing order
for j = size(Acontrol, 1): -1: 1
    Acontrolavgcasesvec = [Acontrolavgcasesvec Acontrol(j, 1)];
    Acontroldeathsavgvec = [Acontroldeathsavgvec Acontrol(j, 2)];
end
mylin = linspace(1, size(Acontrol, 1), size(Acontrol, 1));
%The values for each day (cases and deaths)
Avaluescases = fnval(Acscases, mylin);
Avaluesdeaths = fnval(Acsdeaths, mylin);
%For each day, we evaluate what is the error between the interpolation and
%the control values
for i = 1: size(Acontrol, 1)
    AErrorsavgCases = [AErrorsavgCases abs(Avaluescases(i) - Acontrolavgcasesvec(i))];
    AErrorsavgDeaths = [AErrorsavgDeaths abs(Avaluesdeaths(i) - Acontroldeathsavgvec(i))];
end

%Absolute total error on cases and deaths
ATotalErrorCasesavg = 0;
AControlCasesavg = 0;
for i=1:length(AErrorsavgCases)
    ATotalErrorCasesavg = ATotalErrorCasesavg + AErrorsavgCases(i);
    AControlCasesavg = AControlCasesavg + Acontrol(i,1);
end
ATotalErrorDeathsavg = 0;
AControlDeathsavg = 0;
for i=1:length(AErrorsavgDeaths)
    ATotalErrorDeathsavg = ATotalErrorDeathsavg + AErrorsavgDeaths(i);
    AControlDeathsavg = AControlDeathsavg + Acontrol(i,2);
end

%Relative total error on cases and deaths (should put in absolute value)
ARelErrorCasesavg = ATotalErrorCasesavg/AControlCasesavg;
ARelErrorDeathsavg = ATotalErrorDeathsavg/AControlDeathsavg;
       

%BRAZIL:average between the past 7 days up to a certain given day
Bsizematrix = size(brainfo);
Bnumofrows = Bsizematrix(1);
Baveragematrix = brainfo;

for i=1:(Bnumofrows-7)
    %Initialize the average values
    Baveragecases = 0;
    Baveragedeaths = 0;
    for j = i:i+7
        Baveragecases = Baveragecases + Baveragematrix(j,1);
        Baveragedeaths = Baveragedeaths + Baveragematrix(j,2);
    end
    Baveragecases = Baveragecases / 8;
    Baveragedeaths = Baveragedeaths / 8;
    Baveragematrix(i,1) = Baveragecases;
    Baveragematrix(i,2) = Baveragedeaths;
end

%control sample and working sample
Bcontrol = Baveragematrix(1:2:end,:);
Bworking = Baveragematrix(2:2:end,:);

%Interpolation, create the vector
Bworkingvcases = [];
Bworkingvdeaths = [];
for m = size(Bworking):-1:1
    Bworkingvcases = [Bworkingvcases Bworking(m, 1)];
    Bworkingvdeaths = [Bworkingvdeaths Bworking(m, 2)];
end

%Repeating process without averaging:
Bcontrol2 = brainfo(1:2:end,:);
Bworking2 = brainfo(2:2:end,:);

%Interpolation, create the vector
Bworking2vcases = [];
Bworking2vdeaths = [];
for m = size(Bworking2):-1:1
    Bworking2vcases = [Bworking2vcases Bworking2(m, 1)];
    Bworking2vdeaths = [Bworking2vdeaths Bworking2(m, 2)];
end

%Obtain the interpolated functions
vectx = [];
for k = 1:size(Bworking)
    vectx = [vectx k];
end
x = vectx;
y = Bworkingvcases;
g = Bworkingvdeaths;
%Interpolate the data
Bcscases = csapi(x, y);
Bcsdeaths = csapi(x,g);

%Interpolating without averaging   
x2=vectx;
y2=Bworking2vcases;
g2=Bworking2vdeaths;
%Interpolate the data and then plot it in a graph
Bcscases2 = csapi(x2, y2);
Bcsdeaths2 = csapi(x2,g2);

%MEASURE: Calculation of errors in Brazil
%NOT AVERAGE ERRORS
%Matrix of absolute errors by day (control day sample):
BErrorsCases = [];
BErrorsDeaths = [];
Bcontrolcasesvec = [];
Bcontroldeathsvec = [];

%Flip the vector so we have an increasing order
for j = size(Bcontrol2, 1): -1: 1
    Bcontrolcasesvec = [Bcontrolcasesvec Bcontrol2(j, 1)];
    Bcontroldeathsvec = [Bcontroldeathsvec Bcontrol2(j, 2)];
end
mylin = linspace(1, size(Bcontrol2, 1), size(Bcontrol2, 1));
%The values for each day (cases and deaths)
Bvaluescases = fnval(Bcscases2, mylin);
Bvaluesdeaths = fnval(Bcsdeaths2, mylin);
%For each day, we evaluate what is the error between the interpolation and
%the control values
for i = 1: size(Bcontrol2, 1)
    BErrorsCases = [BErrorsCases abs(Bvaluescases(i) - Bcontrolcasesvec(i))];
    BErrorsDeaths = [BErrorsDeaths abs(Bvaluesdeaths(i) - Bcontroldeathsvec(i))];
end

%Absolute total error on cases and deaths
BTotalErrorCases = 0;
BControlCases = 0;
for i=1:length(BErrorsCases)
    BTotalErrorCases = BTotalErrorCases + BErrorsCases(i);
    BControlCases = BControlCases + Bcontrol2(i,1);
end
BTotalErrorDeaths = 0;
BControlDeaths = 0;
for i=1:length(BErrorsDeaths)
    BTotalErrorDeaths = BTotalErrorDeaths + BErrorsDeaths(i);
    BControlDeaths = BControlDeaths + Bcontrol2(i,2);
end

%Relative total error on cases and deaths (should put in absolute value)
BRelErrorCases = BTotalErrorCases/BControlCases;
BRelErrorDeaths = BTotalErrorDeaths/BControlDeaths;


%AVERAGE ERRORS
%Matrix of absolute errors by day (control day sample):
BErrorsavgCases = [];
BErrorsavgDeaths = [];
Bcontrolavgcasesvec = [];
Bcontroldeathsavgvec = [];

%Flip the vector so we have an increasing order
for j = size(Bcontrol, 1): -1: 1
    Bcontrolavgcasesvec = [Bcontrolavgcasesvec Bcontrol(j, 1)];
    Bcontroldeathsavgvec = [Bcontroldeathsavgvec Bcontrol(j, 2)];
end
mylin = linspace(1, size(Bcontrol, 1), size(Bcontrol, 1));
%The values for each day (cases and deaths)
Bvaluescases = fnval(Bcscases, mylin);
Bvaluesdeaths = fnval(Bcsdeaths, mylin);
%For each day, we evaluate what is the error between the interpolation and
%the control values
for i = 1: size(Bcontrol, 1)
    BErrorsavgCases = [BErrorsavgCases abs(Bvaluescases(i) - Bcontrolavgcasesvec(i))];
    BErrorsavgDeaths = [BErrorsavgDeaths abs(Bvaluesdeaths(i) - Bcontroldeathsavgvec(i))];
end

%Absolute total error on cases and deaths
BTotalErrorCasesavg = 0;
BControlCasesavg = 0;
for i=1:length(BErrorsavgCases)
    BTotalErrorCasesavg = BTotalErrorCasesavg + BErrorsavgCases(i);
    BControlCasesavg = BControlCasesavg + Bcontrol(i,1);
end
BTotalErrorDeathsavg = 0;
BControlDeathsavg = 0;
for i=1:length(BErrorsavgDeaths)
    BTotalErrorDeathsavg = BTotalErrorDeathsavg + BErrorsavgDeaths(i);
    BControlDeathsavg = BControlDeathsavg + Bcontrol(i,2);
end

%Relative total error on cases and deaths (should put in absolute value)
BRelErrorCasesavg = BTotalErrorCasesavg/BControlCasesavg;
BRelErrorDeathsavg = BTotalErrorDeathsavg/BControlDeathsavg;

%ESP:average between the past 7 days up to a certain given day
Esizematrix = size(espinfo);
Enumofrows = Esizematrix(1);
Eaveragematrix = espinfo;

for i=1:(Enumofrows-7)
    %Initialize the average values
    Eaveragecases = 0;
    Eaveragedeaths = 0;
    for j = i:i+7
        Eaveragecases = Eaveragecases + Eaveragematrix(j,1);
        Eaveragedeaths = Eaveragedeaths + Eaveragematrix(j,2);
    end
    Eaveragecases = Eaveragecases / 8;
    Eaveragedeaths = Eaveragedeaths / 8;
    Eaveragematrix(i,1) = Eaveragecases;
    Eaveragematrix(i,2) = Eaveragedeaths;
end

%control sample and working sample
Econtrol = Eaveragematrix(1:2:end,:);
Eworking = Eaveragematrix(2:2:end,:);

%Interpolation, create the vector
Eworkingvcases = [];
Eworkingvdeaths = [];
for m = size(Eworking):-1:1
    Eworkingvcases = [Eworkingvcases Eworking(m, 1)];
    Eworkingvdeaths = [Eworkingvdeaths Eworking(m, 2)];
end

%Repeating process without averaging:
Econtrol2 = espinfo(1:2:end,:);
Eworking2 = espinfo(2:2:end,:);

%Interpolation, create the vector
Eworking2vcases = [];
Eworking2vdeaths = [];
for m = size(Eworking2):-1:1
    Eworking2vcases = [Eworking2vcases Eworking2(m, 1)];
    Eworking2vdeaths = [Eworking2vdeaths Eworking2(m, 2)];
end

%Obtain the interpolated functions
vectx = [];
for k = 1:size(Eworking)
    vectx = [vectx k];
end
x = vectx;
y = Eworkingvcases;
g = Eworkingvdeaths;
%Interpolate the data
Ecscases = csapi(x, y);
Ecsdeaths = csapi(x,g);
%Interpolating without averaging
x2=vectx;
y2=Eworking2vcases;
g2=Eworking2vdeaths;
%Interpolate the data
Ecscases2 = csapi(x2, y2);
Ecsdeaths2 = csapi(x2,g2);

%MEASURE: Calculation of errors in Spain
%NOT AVERAGE ERRORS
%Matrix of absolute errors by day (control day sample):
EErrorsCases = [];
EErrorsDeaths = [];
Econtrolcasesvec = [];
Econtroldeathsvec = [];

%Flip the vector so we have an increasing order
for j = size(Econtrol2, 1): -1: 1
    Econtrolcasesvec = [Econtrolcasesvec Econtrol2(j, 1)];
    Econtroldeathsvec = [Econtroldeathsvec Econtrol2(j, 2)];
end
mylin = linspace(1, size(Econtrol2, 1), size(Econtrol2, 1));
%The values for each day (cases and deaths)
Evaluescases = fnval(Ecscases2, mylin);
Evaluesdeaths = fnval(Ecsdeaths2, mylin);
%For each day, we evaluate what is the error between the interpolation and
%the control values
for i = 1: size(Econtrol2, 1)
    EErrorsCases = [EErrorsCases abs(Evaluescases(i) - Econtrolcasesvec(i))];
    EErrorsDeaths = [EErrorsDeaths abs(Evaluesdeaths(i) - Econtroldeathsvec(i))];
end

%Absolute total error on cases and deaths
ETotalErrorCases = 0;
EControlCases = 0;
for i=1:length(EErrorsCases)
    ETotalErrorCases = ETotalErrorCases + EErrorsCases(i);
    EControlCases = EControlCases + Econtrol2(i,1);
end
ETotalErrorDeaths = 0;
EControlDeaths = 0;
for i=1:length(EErrorsDeaths)
    ETotalErrorDeaths = ETotalErrorDeaths + EErrorsDeaths(i);
    EControlDeaths = EControlDeaths + Econtrol2(i,2);
end

%Relative total error on cases and deaths (should put in absolute value)
ERelErrorCases = ETotalErrorCases/EControlCases;
ERelErrorDeaths = ETotalErrorDeaths/EControlDeaths;


%AVERAGE ERRORS
%Matrix of absolute errors by day (control day sample):
EErrorsavgCases = [];
EErrorsavgDeaths = [];
Econtrolavgcasesvec = [];
Econtroldeathsavgvec = [];

%Flip the vector so we have an increasing order
for j = size(Econtrol, 1): -1: 1
    Econtrolavgcasesvec = [Econtrolavgcasesvec Econtrol(j, 1)];
    Econtroldeathsavgvec = [Econtroldeathsavgvec Econtrol(j, 2)];
end
mylin = linspace(1, size(Econtrol, 1), size(Econtrol, 1));
%The values for each day (cases and deaths)
Evaluescases = fnval(Ecscases, mylin);
Evaluesdeaths = fnval(Ecsdeaths, mylin);
%For each day, we evaluate what is the error between the interpolation and
%the control values
for i = 1: size(Econtrol, 1)
    EErrorsavgCases = [EErrorsavgCases abs(Evaluescases(i) - Econtrolavgcasesvec(i))];
    EErrorsavgDeaths = [EErrorsavgDeaths abs(Evaluesdeaths(i) - Econtroldeathsavgvec(i))];
end

%Absolute total error on cases and deaths
ETotalErrorCasesavg = 0;
EControlCasesavg = 0;
for i=1:length(EErrorsavgCases)
    ETotalErrorCasesavg = ETotalErrorCasesavg + EErrorsavgCases(i);
    EControlCasesavg = EControlCasesavg + Econtrol(i,1);
end
ETotalErrorDeathsavg = 0;
EControlDeathsavg = 0;
for i=1:length(EErrorsavgDeaths)
    ETotalErrorDeathsavg = ETotalErrorDeathsavg + EErrorsavgDeaths(i);
    EControlDeathsavg = EControlDeathsavg + Econtrol(i,2);
end

%Relative total error on cases and deaths (should put in absolute value)
ERelErrorCasesavg = ETotalErrorCasesavg/EControlCasesavg;
ERelErrorDeathsavg = ETotalErrorDeathsavg/EControlDeathsavg;


%PERU:average between the past 7 days up to a certain given day
Psizematrix = size(perinfo);
Pnumofrows = Psizematrix(1);
Paveragematrix = perinfo;

for i=1:(Pnumofrows-7)
    %Initialize the average values
    Paveragecases = 0;
    Paveragedeaths = 0;
    for j = i:i+7
        Paveragecases = Paveragecases + Paveragematrix(j,1);
        Paveragedeaths = Paveragedeaths + Paveragematrix(j,2);
    end
    Paveragecases = Paveragecases / 8;
    Paveragedeaths = Paveragedeaths / 8;
    Paveragematrix(i,1) = Paveragecases;
    Paveragematrix(i,2) = Paveragedeaths;
    
end

%control sample and working sample
Pcontrol = Paveragematrix(1:2:end,:);
Pworking = Paveragematrix(2:2:end,:);

%Interpolation, create the vector
Pworkingvcases = [];
Pworkingvdeaths = [];
for m = size(Pworking):-1:1
    Pworkingvcases = [Pworkingvcases Pworking(m, 1)];
    Pworkingvdeaths = [Pworkingvdeaths Pworking(m, 2)];
end

%Repeating process without averaging:
Pcontrol2 = perinfo(1:2:end,:);
Pworking2 = perinfo(2:2:end,:);

%Interpolation, create the vector
Pworking2vcases = [];
Pworking2vdeaths = [];
for m = size(Pworking2):-1:1
    Pworking2vcases = [Pworking2vcases Pworking2(m, 1)];
    Pworking2vdeaths = [Pworking2vdeaths Pworking2(m, 2)];
end

%Obtain the interpolated functions
vectx = [];
for k = 1:size(Pworking)
    vectx = [vectx k];
end
x = vectx;
y = Pworkingvcases;
g = Pworkingvdeaths;
%Interpolate the data and then plot it in a graph
Pcscases = csapi(x, y);
Pcsdeaths = csapi(x,g);

%Interpolating without averaging
x2=vectx;
y2=Pworking2vcases;
g2=Pworking2vdeaths;
%Interpolate the data and then plot it in a graph
Pcscases2 = csapi(x2, y2);
Pcsdeaths2 = csapi(x2,g2);

%MEASURE: Calculation of errors in Peru
%NOT AVERAGE ERRORS
%Matrix of absolute errors by day (control day sample):
PErrorsCases = [];
PErrorsDeaths = [];
Pcontrolcasesvec = [];
Pcontroldeathsvec = [];  

%Flip the vector so we have an increasing order
for j = size(Pcontrol2, 1): -1: 1
    Pcontrolcasesvec = [Pcontrolcasesvec Pcontrol2(j, 1)];
    Pcontroldeathsvec = [Pcontroldeathsvec Pcontrol2(j, 2)];
end 
mylin = linspace(1, size(Pcontrol2, 1), size(Pcontrol2, 1));
%The values for each day (cases and deaths)
Pvaluescases = fnval(Pcscases2, mylin);
Pvaluesdeaths = fnval(Pcsdeaths2, mylin);
%For each day, we evaluate what is the error between the interpolation and
%the control values
for i = 1: size(Pcontrol2, 1)
    PErrorsCases = [PErrorsCases abs(Pvaluescases(i) - Pcontrolcasesvec(i))];
    PErrorsDeaths = [PErrorsDeaths abs(Pvaluesdeaths(i) - Pcontroldeathsvec(i))];
end

%Absolute total error on cases and deaths
PTotalErrorCases = 0;
PControlCases = 0;
for i=1:length(PErrorsCases)
    PTotalErrorCases = PTotalErrorCases + PErrorsCases(i);
    PControlCases = PControlCases + Pcontrol2(i,1);
end
PTotalErrorDeaths = 0;
PControlDeaths = 0;
for i=1:length(PErrorsDeaths)
    PTotalErrorDeaths = PTotalErrorDeaths + PErrorsDeaths(i);
    PControlDeaths = PControlDeaths + Pcontrol2(i,2);
end

%Relative total error on cases and deaths (should put in absolute value)
PRelErrorCases = PTotalErrorCases/PControlCases;
PRelErrorDeaths = PTotalErrorDeaths/PControlDeaths;


%AVERAGE ERRORS
%Matrix of absolute errors by day (control day sample):
PErrorsavgCases = [];
PErrorsavgDeaths = [];
Pcontrolavgcasesvec = [];
Pcontroldeathsavgvec = [];

%Flip the vector so we have an increasing order
for j = size(Pcontrol, 1): -1: 1
    Pcontrolavgcasesvec = [Pcontrolavgcasesvec Pcontrol(j, 1)];
    Pcontroldeathsavgvec = [Pcontroldeathsavgvec Pcontrol(j, 2)];
end
mylin = linspace(1, size(Pcontrol, 1), size(Pcontrol, 1));
%The values for each day (cases and deaths)
Pvaluescases = fnval(Pcscases, mylin);
Pvaluesdeaths = fnval(Pcsdeaths, mylin);
%For each day, we evaluate what is the error between the interpolation and
%the control values
for i = 1: size(Pcontrol, 1)
    PErrorsavgCases = [PErrorsavgCases abs(Pvaluescases(i) - Pcontrolavgcasesvec(i))];
    PErrorsavgDeaths = [PErrorsavgDeaths abs(Pvaluesdeaths(i) - Pcontroldeathsavgvec(i))];
end

%Absolute total error on cases and deaths
PTotalErrorCasesavg = 0;
PControlCasesavg = 0;
for i=1:length(PErrorsavgCases)
    PTotalErrorCasesavg = PTotalErrorCasesavg + PErrorsavgCases(i);
    PControlCasesavg = PControlCasesavg + Pcontrol(i,1);
end
PTotalErrorDeathsavg = 0;
PControlDeathsavg = 0;
for i=1:length(PErrorsavgDeaths)
    PTotalErrorDeathsavg = PTotalErrorDeathsavg + PErrorsavgDeaths(i);
    PControlDeathsavg = PControlDeathsavg + Pcontrol(i,2);
end

%Relative total error on cases and deaths (should put in absolute value)
PRelErrorCasesavg = PTotalErrorCasesavg/PControlCasesavg;
PRelErrorDeathsavg = PTotalErrorDeathsavg/PControlDeathsavg;

%Now the user chooses which info to view
ask = input ('Show data from: ','s');
if (ask == 'ARG')
    %CASES GRAPHS
    figure('Name','Argentina: Cases');
    hold on;
    %Without interpolation cases
    vecsize = size(arginfo(:,1));
    x = [1:vecsize(1)];
    y = arginfo(vecsize: -1: 1, 1);
    plot(x, y, '.', x, Aaveragematrix(vecsize:-1:1, 1), '+');
    %Interpolated cases
    Acasesfun = csapi(x, arginfo(vecsize: -1: 1, 1));
    Aaveragecasesfun = csapi(x, Aaveragematrix(vecsize:-1:1, 1));
    fnplt(Acasesfun, 'g', 1);
    fnplt(Aaveragecasesfun, 'k', 1);
    hold off;
    
    %DEATHS GRAPH
    figure('Name', 'Argentina: Deaths');
    hold on;
    %Without interpolation deaths
    y = arginfo(vecsize: -1: 1, 2);
    plot(x, y, '.', x, Aaveragematrix(vecsize:-1:1,2), '+');
    %Interpolated cases
    Adeathsfun = csapi(x, arginfo(vecsize: -1: 1, 2));
    Aaveragedeathsfun = csapi(x, Aaveragematrix(vecsize:-1:1, 2));
    fnplt(Adeathsfun, 'g', 1);
    fnplt(Aaveragedeathsfun, 'k', 1);
    hold off;
   
elseif (ask == 'BRA')
    %CASES GRAPHS
    figure('Name','Brazil: Cases');
    hold on;
    %Without interpolation cases
    vecsize = size(brainfo(:,1));
    x = [1:vecsize(1)];
    y = brainfo(vecsize: -1: 1, 1);
    plot(x, y, '.', x, Baveragematrix(vecsize:-1:1, 1), '+');
    %Interpolated cases
    Bcasesfun = csapi(x, brainfo(vecsize: -1: 1, 1));
    Baveragecasesfun = csapi(x, Baveragematrix(vecsize:-1:1, 1));
    fnplt(Bcasesfun, 'g', 1);
    fnplt(Baveragecasesfun, 'k', 1);
    hold off;
    
    %DEATHS GRAPH
    figure('Name', 'Brazil: Deaths');
    hold on;
    %Without interpolation deaths
    y = brainfo(vecsize: -1: 1, 2);
    plot(x, y, '.', x, Baveragematrix(vecsize:-1:1,2), '+');
    %Interpolated cases
    Bdeathsfun = csapi(x, brainfo(vecsize: -1: 1, 2));
    Baveragedeathsfun = csapi(x, Baveragematrix(vecsize:-1:1, 2));
    fnplt(Bdeathsfun, 'g', 1);
    fnplt(Baveragedeathsfun, 'k', 1);
    hold off;

elseif (ask == 'ESP')
    %CASES GRAPHS
    figure('Name','Spain: Cases');
    hold on;
    %Without interpolation cases
    vecsize = size(espinfo(:,1));
    x = [1:vecsize(1)];
    y = espinfo(vecsize: -1: 1, 1);
    plot(x, y, '.', x, Eaveragematrix(vecsize:-1:1, 1), '+');
    %Interpolated cases
    Ecasesfun = csapi(x, espinfo(vecsize: -1: 1, 1));
    Eaveragecasesfun = csapi(x, Eaveragematrix(vecsize:-1:1, 1));
    fnplt(Ecasesfun, 'g', 1);
    fnplt(Eaveragecasesfun, 'k', 1);
    hold off;
    
    %DEATHS GRAPH
    figure('Name', 'Spain: Deaths');
    hold on;
    %Without interpolation deaths
    y = espinfo(vecsize: -1: 1, 2);
    plot(x, y, '.', x, Eaveragematrix(vecsize:-1:1,2), '+');
    %Interpolated cases
    Edeathsfun = csapi(x, espinfo(vecsize: -1: 1, 2));
    Eaveragedeathsfun = csapi(x, Eaveragematrix(vecsize:-1:1, 2));
    fnplt(Edeathsfun, 'g', 1);
    fnplt(Eaveragedeathsfun, 'k', 1);
    hold off;
   
elseif (ask == 'PER')
    %CASES GRAPHS
    figure('Name','Peru: Cases');
    hold on;
    %Without interpolation cases
    vecsize = size(perinfo(:,1));
    x = [1:vecsize(1)];
    y = perinfo(vecsize: -1: 1, 1);
    plot(x, y, '.', x, Paveragematrix(vecsize:-1:1, 1), '+');
    %Interpolated cases
    Pcasesfun = csapi(x, perinfo(vecsize: -1: 1, 1));
    Paveragecasesfun = csapi(x, Paveragematrix(vecsize:-1:1, 1));
    fnplt(Pcasesfun, 'g', 1);
    fnplt(Paveragecasesfun, 'k', 1);
    hold off;
    
    %DEATHS GRAPH
    figure('Name', 'Peru: Deaths');
    hold on;
    %Without interpolation deaths
    y = perinfo(vecsize: -1: 1, 2);
    plot(x, y, '.', x, Paveragematrix(vecsize:-1:1,2), '+');
    %Interpolated cases
    Pdeathsfun = csapi(x, perinfo(vecsize: -1: 1, 2));
    Paveragedeathsfun = csapi(x, Paveragematrix(vecsize:-1:1, 2));
    fnplt(Pdeathsfun, 'g', 1);
    fnplt(Paveragedeathsfun, 'k', 1);
    hold off;
elseif (ask == 'ALL')
    %Question 1
    disp('Question 1: GENERAL RANKING');
    disp('RANKING: ');
    disp('1.Brazil:');
    fprintf('\n-cases error=%.4f',BRelErrorCases);
    fprintf('\n-deaths error=%0.4f\n',BRelErrorDeaths);
    disp('2.Spain:');
    fprintf('\n-cases error=%.4f',ERelErrorCases);
    fprintf('\n-deaths error=%0.4f\n',ERelErrorDeaths);
    disp('3.Argentina:');
    fprintf('\n-cases error=%.4f',ARelErrorCases);
    fprintf('\n-deaths error=%0.4f\n',ARelErrorDeaths);
    disp('4.Peru: ');
    fprintf('\n-cases error=%.4f',PRelErrorCases);
    fprintf('\n-deaths error=%0.4f\n',PRelErrorDeaths);
    
    disp('CASES RANKING: ');
    disp('1.Argentina:');
    fprintf('\n-cases error=%.4f\n',ARelErrorCases);
    disp('2.Peru: ');
    fprintf('\n-cases error=%.4f\n',PRelErrorCases);
    disp('3.Brazil:');
    fprintf('\n-cases error=%.4f\n',BRelErrorCases);
    disp('4.Spain:');
    fprintf('\n-cases error=%.4f\n',ERelErrorCases);
    
    disp('DEATHS RANKING: ');
    disp('1.Spain:');
    fprintf('\n-deaths error=%0.4f\n',ERelErrorDeaths);
    disp('2.Brazil:');
    fprintf('\n-deaths error=%0.4f\n',BRelErrorDeaths);
    disp('3.Argentina:');
    fprintf('\n-deaths error=%0.4f\n',ARelErrorDeaths);
    disp('4.Peru: ');
    fprintf('\n-deaths error=%0.4f\n',PRelErrorDeaths);
    
    %Question 2
    disp('Question 2:');
    disp('In relative terms, deaths are more predictible since, as you can see on the graphs, the numbers are more stable.' );
    disp('The smoother a function is, the easier it is to find a prediction, that''s why deaths are more predictible');
    
    %Question 3
    fprintf('\nQuestion 3:\n');
    
    %Argetina day 1 = 6/6 = saturday (SAT)
    Aday1cases=0;
    Aday2cases=0;
    Aday3cases=0;
    Aday4cases=0;
    Aday5cases=0;
    Aday6cases=0;
    Aday7cases=0;
    Aday1deaths=0;
    Aday2deaths=0;
    Aday3deaths=0;
    Aday4deaths=0;
    Aday5deaths=0;
    Aday6deaths=0;
    Aday7deaths=0;
    for (i=1:7:length(AErrorsavgCases))
        Aday1cases = Aday1cases + AErrorsavgCases(i);
        Aday1deaths = Aday1deaths + AErrorsavgDeaths(i);
    end
    for (i=2:7:length(AErrorsavgCases))
        Aday2cases = Aday2cases + AErrorsavgCases(i);
        Aday2deaths = Aday2deaths + AErrorsavgDeaths(i);
    end
    for (i=3:7:length(AErrorsavgCases))
        Aday3cases = Aday3cases + AErrorsavgCases(i);
        Aday3deaths = Aday3deaths + AErrorsavgDeaths(i);
    end
    for (i=4:7:length(AErrorsavgCases))
        Aday4cases = Aday4cases + AErrorsavgCases(i);
        Aday4deaths = Aday4deaths + AErrorsavgDeaths(i);
    end
    for (i=5:7:length(AErrorsavgCases))
        Aday5cases = Aday5cases + AErrorsavgCases(i);
        Aday5deaths = Aday5deaths + AErrorsavgDeaths(i);
    end
    for (i=6:7:length(AErrorsavgCases))
        Aday6cases = Aday6cases + AErrorsavgCases(i);
        Aday6deaths = Aday6deaths + AErrorsavgDeaths(i);
    end
    for (i=7:7:length(AErrorsavgCases))
        Aday7cases = Aday7cases + AErrorsavgCases(i);
        Aday7deaths = Aday7deaths + AErrorsavgDeaths(i);
    end
    ATotalCasesErrorByDay = [Aday1cases Aday2cases Aday3cases Aday4cases Aday5cases Aday6cases Aday7cases];
    ATotalDeathErrorByDay = [Aday1deaths Aday2deaths Aday3deaths Aday4deaths Aday5deaths Aday6deaths Aday7deaths];
    fprintf('\nARGENTINA:\n')
    disp('Total error during the timeline by day of week (day 1 = Saturday):')
    for i=1:7
        val1 = ATotalCasesErrorByDay(i);
        val2 = ATotalDeathErrorByDay(i);
        fprintf('Day %d: %.2f on cases, %.2f on deaths \n', i, val1, val2);
    end
    fprintf('The quality of the weekly average death reports was considerably worse on Fridays (day 7)\n');
    
    %Brasil day 1 = 1/4 = wednesday (WED)
    Bday1cases=0;
    Bday2cases=0;
    Bday3cases=0;
    Bday4cases=0;
    Bday5cases=0;
    Bday6cases=0;
    Bday7cases=0;
    Bday1deaths=0;
    Bday2deaths=0;
    Bday3deaths=0;
    Bday4deaths=0;
    Bday5deaths=0;
    Bday6deaths=0;
    Bday7deaths=0;
    for (i=1:7:length(BErrorsavgCases))
        Bday1cases = Bday1cases + BErrorsavgCases(i);
        Bday1deaths = Bday1deaths + BErrorsavgDeaths(i);
    end
    for (i=2:7:length(BErrorsavgCases))
        Bday2cases = Bday2cases + BErrorsavgCases(i);
        Bday2deaths = Bday2deaths + BErrorsavgDeaths(i);
    end
    for (i=3:7:length(BErrorsavgCases))
        Bday3cases = Bday3cases + BErrorsavgCases(i);
        Bday3deaths = Bday3deaths + BErrorsavgDeaths(i);
    end
    for (i=4:7:length(BErrorsavgCases))
        Bday4cases = Bday4cases + BErrorsavgCases(i);
        Bday4deaths = Bday4deaths + BErrorsavgDeaths(i);
    end
    for (i=5:7:length(BErrorsavgCases))
        Bday5cases = Bday5cases + BErrorsavgCases(i);
        Bday5deaths = Bday5deaths + BErrorsavgDeaths(i);
    end
    for (i=6:7:length(BErrorsavgCases))
        Bday6cases = Bday6cases + BErrorsavgCases(i);
        Bday6deaths = Bday6deaths + BErrorsavgDeaths(i);
    end
    for (i=7:7:length(BErrorsavgCases))
        Bday7cases = Bday7cases + BErrorsavgCases(i);
        Bday7deaths = Bday7deaths + BErrorsavgDeaths(i);
    end
    BTotalCasesErrorByDay = [Bday1cases Bday2cases Bday3cases Bday4cases Bday5cases Bday6cases Bday7cases];
    BTotalDeathErrorByDay = [Bday1deaths Bday2deaths Bday3deaths Bday4deaths Bday5deaths Bday6deaths Bday7deaths];
    fprintf('\nBRASIL:\n')
    disp('Total error during the timeline by day of week (day 1 = Wednesday):')
    for i=1:7
        val1 = BTotalCasesErrorByDay(i);
        val2 = BTotalDeathErrorByDay(i);
        fprintf('Day %d: %.2f on cases, %.2f on deaths \n', i, val1, val2);
    end
    fprintf('The quality of the weekly average reports, both on deaths and cases,\nwas considerably worse on Thursdays (day 2) and Saturdays (day4)\n');
   
    %España day 1 = 8/3 = sunday (SUN)
    Eday1cases=0;
    Eday2cases=0;
    Eday3cases=0;
    Eday4cases=0;
    Eday5cases=0;
    Eday6cases=0;
    Eday7cases=0;
    Eday1deaths=0;
    Eday2deaths=0;
    Eday3deaths=0;
    Eday4deaths=0;
    Eday5deaths=0;
    Eday6deaths=0;
    Eday7deaths=0;
    for (i=1:7:length(EErrorsavgCases))
        Eday1cases = Eday1cases + EErrorsavgCases(i);
        Eday1deaths = Eday1deaths + EErrorsavgDeaths(i);
    end
    for (i=2:7:length(EErrorsavgCases))
        Eday2cases = Eday2cases + EErrorsavgCases(i);
        Eday2deaths = Eday2deaths + EErrorsavgDeaths(i);
    end
    for (i=3:7:length(EErrorsavgCases))
        Eday3cases = Eday3cases + EErrorsavgCases(i);
        Eday3deaths = Eday3deaths + EErrorsavgDeaths(i);
    end
    for (i=4:7:length(EErrorsavgCases))
        Eday4cases = Eday4cases + EErrorsavgCases(i);
        Eday4deaths = Eday4deaths + EErrorsavgDeaths(i);
    end
    for (i=5:7:length(EErrorsavgCases))
        Eday5cases = Eday5cases + EErrorsavgCases(i);
        Eday5deaths = Eday5deaths + EErrorsavgDeaths(i);
    end
    for (i=6:7:length(EErrorsavgCases))
        Eday6cases = Eday6cases + EErrorsavgCases(i);
        Eday6deaths = Eday6deaths + EErrorsavgDeaths(i);
    end
    for (i=7:7:length(EErrorsavgCases))
        Eday7cases = Eday7cases + EErrorsavgCases(i);
        Eday7deaths = Eday7deaths + EErrorsavgDeaths(i);
    end
    ETotalCasesErrorByDay = [Eday1cases Eday2cases Eday3cases Eday4cases Eday5cases Eday6cases Eday7cases];
    ETotalDeathErrorByDay = [Eday1deaths Eday2deaths Eday3deaths Eday4deaths Eday5deaths Eday6deaths Eday7deaths];
    fprintf('\nESPAÑA:\n')
    disp('Total error during the timeline by day of week (day 1 = Sunday):')
    for i=1:7
        val1 = ETotalCasesErrorByDay(i);
        val2 = ETotalDeathErrorByDay(i);
        fprintf('Day %d: %.2f on cases, %.2f on deaths \n', i, val1, val2);
    end
    fprintf('The quality of the weekly average cases reports was considerably worse on Saturdays (day 7)\nand Mondays(day 2), while the quality of the weekly average death reports\ndecreased on Mondays (day 2), Wednesdays (day 4) and Thursdays (day 5)\n');
    
    %Peru day 1 = 9/4 = thursday (THU)
    Pday1cases=0;
    Pday2cases=0;
    Pday3cases=0;
    Pday4cases=0;
    Pday5cases=0;
    Pday6cases=0;
    Pday7cases=0;
    Pday1deaths=0;
    Pday2deaths=0;
    Pday3deaths=0;
    Pday4deaths=0;
    Pday5deaths=0;
    Pday6deaths=0;
    Pday7deaths=0;
    for (i=1:7:length(PErrorsavgCases))
        Pday1cases = Pday1cases + PErrorsavgCases(i);
        Pday1deaths = Pday1deaths + PErrorsavgDeaths(i);
    end
    for (i=2:7:length(PErrorsavgCases))
        Pday2cases = Pday2cases + PErrorsavgCases(i);
        Pday2deaths = Pday2deaths + PErrorsavgDeaths(i);
    end
    for (i=3:7:length(PErrorsavgCases))
        Pday3cases = Pday3cases + PErrorsavgCases(i);
        Pday3deaths = Pday3deaths + PErrorsavgDeaths(i);
    end
    for (i=4:7:length(PErrorsavgCases))
        Pday4cases = Pday4cases + PErrorsavgCases(i);
        Pday4deaths = Pday4deaths + PErrorsavgDeaths(i);
    end
    for (i=5:7:length(PErrorsavgCases))
        Pday5cases = Pday5cases + PErrorsavgCases(i);
        Pday5deaths = Pday5deaths + PErrorsavgDeaths(i);
    end
    for (i=6:7:length(PErrorsavgCases))
        Pday6cases = Pday6cases + PErrorsavgCases(i);
        Pday6deaths = Pday6deaths + PErrorsavgDeaths(i);
    end
    for (i=7:7:length(PErrorsavgCases))
        Pday7cases = Pday7cases + PErrorsavgCases(i);
        Pday7deaths = Pday7deaths + PErrorsavgDeaths(i);
    end
    PTotalCasesErrorByDay = [Pday1cases Pday2cases Pday3cases Pday4cases Pday5cases Pday6cases Pday7cases];
    PTotalDeathErrorByDay = [Pday1deaths Pday2deaths Pday3deaths Pday4deaths Pday5deaths Pday6deaths Pday7deaths];
    fprintf('\nPERU\n')
    disp('Total error during the timeline by day of week (day 1 = Thursday):')
    for i=1:7
        val1 = PTotalCasesErrorByDay(i);
        val2 = PTotalDeathErrorByDay(i);
        fprintf('Day %d: %.2f on cases, %.2f on deaths \n', i, val1, val2);
    end
    fprintf('The quality of the weekly average death reports was considerably worse on Saturdays (day 3),\nwhile in terms of cases, it was the worst on Thursdays (day 1)');
    
end