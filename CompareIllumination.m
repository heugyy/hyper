data_old = Load_Spec('illumination_old.dat');
spectral_old = data_old(600:700, 700:800,:);
spectral_old = reshape(spectral_old, 101*101, 61);
s1 = mean(spectral_old,1);

data_new = Load_Spec('illumination_new.dat');
spectral_new = data_new(600:700, 700:800,:);
spectral_new = reshape(spectral_new, 101*101, 61);
s2 = mean(spectral_new,1);

data = Load_Spec('illumination_new_withoutglass.dat');
spectral = data(600:700, 700:800,:);
spectral = reshape(spectral, 101*101, 61);
s3 = mean(spectral,1);

plot(400:10:1000, s1,'r*', 400:10:1000, s2,'b-', 400:10:1000, s3, 'go');
