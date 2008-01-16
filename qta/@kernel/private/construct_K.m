function K = construct_K(name,p,A)

switch lower(name)
  
  case {'laplace','fibre von mises fisher','square singularity',...
      'gauss weierstrass','dirichlet','user'}
    
    K   = @(co2) ClenshawU(A,acos(co2)*2);
        
  case 'abel poisson'
        
    K   = @(co2) 0.5*((1-p^2)./(1-2*p*co2+p^2).^2+...
					(1-p^2)./(1+2*p*co2+p^2).^2);
				        
  case 'de la vallee poussin'
    
    K   = @(co2) beta(1.5,0.5)/beta(1.5,p+0.5) * co2.^(2*p);
		
  case 'von mises fisher'
	
    if p < 500
      K   = @(co2) 1/(besseli(0,p)-besseli(1,p))...
        * exp(p*cos(acos(co2)*2));
      
    else      
      error('too small halfwidth - not yet supported');
    end
        
  case 'local'
    
    h     = p-1;
    diff  = -5120*h^5 - 2516480/231*h^6 - 1238528/143*h^7 - ...
      2884352/1001*h^8 - 327821248/1072071*h^9 - ...
      335519200/6789783*h^10 + 297252224/74687613*h^11 - ...
      6819984608/5153445297*h^12 + 10609776512/22331596287*h^13 - ...
      27354944/151915621*h^14 + 2986921984/42053005995*h^15 - ...
      44603484928/1544315774001*h^16 + 20524968991232/1706468930271105*h^17 - ...
      7128109283584/1396201852039995*h^18;
    p2  = 30*pi*( sqrt(1 - p^2) *...
      (16 + 83 * p^2 + 6 * p^4) + ...
      15 * p * (3 + 4*p^2) * acos(p)...
      )/diff;

    K   = @(co2) (co2>p).* p2 .* (co2 - p).^3;
		
  otherwise
    K = [];

end


