% PLOT_STANDARD_SAL is a script to plot the standard salinities
% measured by the salinomenter.


% these are copied from SALTS/standard_salinities by hand

samdate = {'27.10.09'
           '31.10.09'
           '01.11.09'
           '01.11.09'
           '05.11.09'
           '05.11.09'
          };

mday = datenum(samdate,'dd.mm.yy');

celltemp = [27
            24
            24
            24
            24
            24];

sambeg = {'P150'
          'P148'
          'P150'
          'P150'
          'P150'
          'P148'
         };

sammid = {'P150'
          'P148'
          'P150'
          'P150'
          'P150'
          'P148'
         };

samend = {'P150'
          'P150'
          'P150'
          '-'
          'P150'
          '-'
         };

salbeg = [1.99956
          1.99913
          1.99905
          1.99904
          1.99905
          1.99912
         ];

salmid = [1.99955
          1.99915
          1.99908
          1.99906
          1.99912
          1.99913
         ];
    
salend = [1.99956
          1.99907
          1.99904
          nan
          1.99912
          nan
         ];


figure

if 1==0 % plot the change from session to session, lines are beg/mid/end
        % values
  x = 1:4;
  plot(x,salbeg,'xk-',x,salmid,'xb-',x,salend,'xr-')
  legend('beginning','middle','end')
  ylabel('conductivity ratio')
  xlabel('testing date')
  set(gca,'xtick',1:4,'xticklabel',{'27.10.09','31.10.09', ...
                      '01.11.09','01.11.09'})

elseif 1==0 % plot the change over each session, lines are
            % different sessions
  x = 1:3;
  plot(x,[salbeg salmid salend],'x-')
  legend(samdate)
  set(gca,'xtick',1:3,'xticklabel',{'beginning','middle','end'})
  ylabel('conductivity ratio')
  xlabel('when standard salinity measured')
  grid on
  title(['Stability of standard salinity samples over each salinometer session'])

elseif 1==1 % plot the change versus date, lines are beg/mid/end values
  x = mday;
  plot(mday-mday(1),[salbeg salmid salend] - salbeg(1),'*-')
  legend({'beginning','middle','end'})
  ylabel('conductivity ratio - first value')
  xlabel('days since first salinometer reading')
  grid on
  title(['Stability of standard salinity samples'])
end

outdir = '/Users/zszuts/cruises/d344/ctd/'; % if on panulirus
outfile = [outdir 'pdf/standard_salinities'];

saveas(gcf,[outfile '.pdf'],'pdf')
