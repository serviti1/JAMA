% function [m_par, b_par] = eog
eog_horizontal = EOG(1,:);
eog_horizontal_filtrado=filter([1 0 -1],[1 -1.99 0.99], eog_horizontal);
eog_horizontal_filtrado2=filter([1 0 -1],[1 -0.41 0.21], eog_horizontal_filtrado);
TargetGA_horizontal=TargetGA(:,1); %5.71 es el angulo 
control_truqueado=ControlSignal*100;

samplerate=256;
grados=[];

for i=1:length(TargetGA_horizontal)
    g=TargetGA_horizontal(i);
    if g ~= 0
        m=repmat(g, round(samplerate)*2,1);
    else 
        m=zeros(round(samplerate)*2,1);
    end
    grados = [grados; m];
    samplerate=samplerate+samplerate*0.00006;
end

close all;
plot(eog_horizontal,'b');
hold on;
plot(eog_horizontal_filtrado2,'m');
hold on;
plot(control_truqueado,'o');
grados_escalado=grados*50;
hold on;
plot(grados_escalado,'*');
xlabel('Time')
ylabel('Voltage (uV)')
legend('Raw data', 'Filtered signal', 'Occular event', 'Degrees of movement')

%%

i=1;
j=1;
g=grados(i);
g_next=grados(i+1);
datos = [];
mV=eog_horizontal_filtrado2(j);

while true
    temp = [];
  
    while g == g_next
        temp = [temp;mV];
        j=j+1;
        if j > size(EOG,2)-2
            break;
        end
        i=i+1;
        g=grados(i);
        g_next=grados(i+1);
        mV=eog_horizontal_filtrado2(j);
    end
    
    truqueo_abajo=750;
    truqueo_arriba=1200;
    n=0; p=0;
    m=j+1;
    
    if j>truqueo_abajo+1
        k = j-truqueo_abajo;
        while p<truqueo_abajo
            temp=[temp;eog_horizontal_filtrado2(k)];
            k=k+1;
            p=p+1;
        end
    end
    while n<truqueo_arriba
        if m > size(EOG,2)-2
            break;
        end
        temp=[temp;eog_horizontal_filtrado2(m)];
        m=m+1;
        n=n+1;
    end
    
    maxmV=max(temp);
    minmV=min(temp);
    
    if g~=0
        if sign(g) == 1
            datos=[datos; g maxmV];
        else 
            datos=[datos;g minmV];
        end
    end 
    if i >= size(EOG,2)-2
            break;
    end
    g=grados(i+1);
    g_next=grados(i+2);
end

hold off;

figure;
x_data=datos(:,1);
y_data=datos(:,2);

y_data=rescale(y_data,0,5);
plot(x_data,y_data,'*');

X = [ones(length(x_data),1) x_data];
b = X\y_data;

b_par=b(1,:);
m_par=b(2,:);
