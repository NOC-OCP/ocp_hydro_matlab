function h = m_editheader(h,ncfile)
% function h = m_editheader(h,ncfile)
%
% edit mstar header

m_common

endflag = 0;
while endflag == 0
    fprintf(MEXEC_A.Mfidterm,'%s\n\n',' ');
    if ~MEXEC_G.quiet; m_print_header(h); end
    m1 = ' Which option ? ';
    m2 = '-1, ''/'' or return: finished (default)';
    m3 = ' 0 all fields';
    m4 = ' 1 dataname';
    m5 = ' 2 platform details';
    m6 = ' 3 instrument/recording interval';
    m7 = ' 4 data time origin';
    m8 = ' 5 position';
    m9 = ' 6 depths';
    m10 = ' 7 comments';
    m11 = ' 8 var names and units';
    m = sprintf('%s\n ',' ',m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11);
    var = m_getinput(m,'s');
    if strcmp(var,' ') == 1; var = '-1'; end
    if strcmp(var,'/') == 1; var = '-1'; end
    if strcmp(var,'-1') == 1;
        endflag = 1;
        break;
    end

    if strcmp(var,'1') == 1 | strcmp(var,'0') == 1
        eflag = 0;
        while eflag == 0
            m = ['Type new dataname (return or / to keep as '  h.dataname ') : '];
            var2 = m_getinput(m,'s');
            if strcmp(var2,' ') == 1;
            elseif strcmp(var2,'/') == 1;
            else
                h.dataname = m_remove_spaces(var2);
            end
            m_write_header(ncfile,h);

            fprintf(MEXEC_A.Mfidterm,'%s\n\n',' ');
            if ~MEXEC_G.quiet; m_print_header(h); end
            m1 = ['Move on to next question ?'];
            m2 = ['type return or / to move on, 1 to repeat'];
            m = sprintf('%s\n',m1,m2);
            var3 = m_getinput(m,'s');
            if strcmp(var3,' ') == 1; eflag = 1; end
            if strcmp(var3,'/') == 1; eflag = 1; end
            if strcmp(var3,'1') == 1; eflag = 0; end
        end
    end

    if strcmp(var,'2') == 1 | strcmp(var,'0') == 1
        eflag = 0;
        while eflag == 0
            m = ['Type new platform type (return or / to keep as '  h.platform_type ') : '];
            var2 = m_getinput(m,'s');
            if strcmp(var2,' ') == 1;
            elseif strcmp(var2,'/') == 1;
            else
                h.platform_type = m_remove_outside_spaces(var2);
            end
            m = ['Type new platform identifier (return or / to keep as '  h.platform_identifier ') : '];
            var2 = m_getinput(m,'s');
            if strcmp(var2,' ') == 1;
            elseif strcmp(var2,'/') == 1;
            else
                h.platform_identifier = m_remove_outside_spaces(var2);
            end
            m = ['Type new platform number (return or / to keep as '  h.platform_number ') : '];
            var2 = m_getinput(m,'s');
            if strcmp(var2,' ') == 1;
            elseif strcmp(var2,'/') == 1;
            else
                h.platform_number = m_remove_outside_spaces(var2);
            end
            m_write_header(ncfile,h);

            fprintf(MEXEC_A.Mfidterm,'%s\n\n',' ');
            if ~MEXEC_G.quiet; m_print_header(h); end
            m1 = ['Move on to next question ?'];
            m2 = ['type return or / to move on, 1 to repeat'];
            m = sprintf('%s\n',m1,m2);
            var3 = m_getinput(m,'s');
            if strcmp(var3,' ') == 1; eflag = 1; end
            if strcmp(var3,'/') == 1; eflag = 1; end
            if strcmp(var3,'1') == 1; eflag = 0; end
        end
    end

    if strcmp(var,'3') == 1 | strcmp(var,'0') == 1
        eflag = 0;
        while eflag == 0
            m = ['Type new instrument identifier (return or / to keep as '  h.instrument_identifier ') : '];
            var2 = m_getinput(m,'s');
            if strcmp(var2,' ') == 1;
            elseif strcmp(var2,'/') == 1;
            else
                h.instrument_identifier = m_remove_outside_spaces(var2);
            end
            m = ['Type new recording interval (return or / to keep as '  h.recording_interval ') : '];
            var2 = m_getinput(m,'s');
            if strcmp(var2,' ') == 1;
            elseif strcmp(var2,'/') == 1;
            else
                h.recording_interval = m_remove_outside_spaces(var2);
            end
            m_write_header(ncfile,h);

            fprintf(MEXEC_A.Mfidterm,'%s\n\n',' ');
            if ~MEXEC_G.quiet; m_print_header(h); end
            m1 = ['Move on to next question ?'];
            m2 = ['type return or / to move on, 1 to repeat'];
            m = sprintf('%s\n',m1,m2);
            var3 = m_getinput(m,'s');
            if strcmp(var3,' ') == 1; eflag = 1; end
            if strcmp(var3,'/') == 1; eflag = 1; end
            if strcmp(var3,'1') == 1; eflag = 0; end
        end
    end

    if strcmp(var,'4') == 1 | strcmp(var,'0') == 1
        eflag = 0;
        while eflag == 0
            m = ['Type new data_time_origin (return or / to keep as ['  sprintf('%d ',h.data_time_origin) '] ) : '];
            var2 = m_getinput(m,'s');
            if strcmp(var2,' ') == 1;
            elseif strcmp(var2,'/') == 1;
            else
                cmd = ['h.data_time_origin = [' var2 '];']; %convert char response to number
                eval(cmd);
                h.data_time_origin_string = datestr(datenum(h.data_time_origin),31);
            end
             m_write_header(ncfile,h);

            fprintf(MEXEC_A.Mfidterm,'%s\n\n',' ');
            if ~MEXEC_G.quiet; m_print_header(h); end
            m1 = ['Move on to next question ?'];
            m2 = ['type return or / to move on, 1 to repeat'];
            m = sprintf('%s\n',m1,m2);
            var3 = m_getinput(m,'s');
            if strcmp(var3,' ') == 1; eflag = 1; end
            if strcmp(var3,'/') == 1; eflag = 1; end
            if strcmp(var3,'1') == 1; eflag = 0; end
        end
    end

    if strcmp(var,'5') == 1 | strcmp(var,'0') == 1
        eflag = 0;
        while eflag == 0
            m = ['Type new lat (return or / to keep as '  sprintf('%12.6f',h.latitude) ' ) : '];
            var2 = m_getinput(m,'s');
            if strcmp(var2,' ') == 1;
            elseif strcmp(var2,'/') == 1;
            else
                cmd = ['lat = [' var2 '];']; %convert char response to number
                eval(cmd);
                h.latitude = lat;
            end
            m = ['Type new lon (return or / to keep as '  sprintf('%12.6f',h.longitude) ' ) : '];
            var2 = m_getinput(m,'s');
            if strcmp(var2,' ') == 1;
            elseif strcmp(var2,'/') == 1;
            else
                cmd = ['lon = [' var2 '];']; %convert char response to number
                eval(cmd);
                h.longitude = lon;
            end
            m_write_header(ncfile,h);


            fprintf(MEXEC_A.Mfidterm,'%s\n\n',' ');
            if ~MEXEC_G.quiet; m_print_header(h); end
            m1 = ['Move on to next question ?'];
            m2 = ['type return or / to move on, 1 to repeat'];
            m = sprintf('%s\n',m1,m2);
            var3 = m_getinput(m,'s');
            if strcmp(var3,' ') == 1; eflag = 1; end
            if strcmp(var3,'/') == 1; eflag = 1; end
            if strcmp(var3,'1') == 1; eflag = 0; end
        end
    end

    if strcmp(var,'6') == 1 | strcmp(var,'0') == 1
        eflag = 0;
        while eflag == 0
            m = ['Type new water_depth_metres      (return or / to keep as '  sprintf('%9.1f',h.water_depth_metres) ' ) : '];
            var2 = m_getinput(m,'s');
            if strcmp(var2,' ') == 1;
            elseif strcmp(var2,'/') == 1;
            else
                cmd = ['water_depth_metres = [' var2 '];']; %convert char response to number
                eval(cmd);
                h.water_depth_metres = water_depth_metres;
            end
            m = ['Type new instrument_depth_metres (return or / to keep as '  sprintf('%9.1f',h.instrument_depth_metres) ' ) : '];
            var2 = m_getinput(m,'s');
            if strcmp(var2,' ') == 1;
            elseif strcmp(var2,'/') == 1;
            else
                cmd = ['instrument_depth_metres = [' var2 '];']; %convert char response to number
                eval(cmd);
                h.instrument_depth_metres = instrument_depth_metres;
            end
            m_write_header(ncfile,h);


            fprintf(MEXEC_A.Mfidterm,'%s\n\n',' ');
            if ~MEXEC_G.quiet; m_print_header(h); end
            m1 = ['Move on to next question ?'];
            m2 = ['type return or / to move on, 1 to repeat'];
            m = sprintf('%s\n',m1,m2);
            var3 = m_getinput(m,'s');
            if strcmp(var3,' ') == 1; eflag = 1; end
            if strcmp(var3,'/') == 1; eflag = 1; end
            if strcmp(var3,'1') == 1; eflag = 0; end
        end
    end

    if strcmp(var,'7') == 1 | strcmp(var,'0') == 1
        eflag = 0;
        while eflag == 0
            disp('Accept or change comments line by line')

            c = h.comment;
            delim = h.comment_delimiter_string;
            h.comment_delimiter_string = delim;
            delimindex = strfind(c,delim); % start locations of delim strings
            ncoms = length(delimindex)-1;
            
            % review/delete/modify existing comments
            
            eflag2 = 0;
            while eflag2 == 0
                m1 = 'Review existing comments (/ or return) or ';
                m2 = 'skip the review and start adding new comments (-1) ?';
                m = sprintf('%s\n',m1,m2);
                var2 = m_getinput(m,'s');
                if strcmp(var2,'-1') == 1; break; end
                % review existing comments
                if ncoms == 0
                    m = 'No exisiting comments to review';
                    fprintf(MEXEC_A.Mfidterm,'%s\n',m);
                    eflag2 = 1;
                else
                    nreview = ncoms; %initial number of comments to review
                    while nreview > 0 % number of comments remaining to review
                        k1 = delimindex(ncoms+1-nreview)+length(delim);
                        k2 = delimindex(ncoms+1-(nreview-1))-1;
                        cstring = ['comment     : ' sprintf('%s',c(k1:k2))];
                        m = sprintf('%s\n%s',cstring, 'Type d to delete,  return or / to accept, or any other string to replace: ');
                        var2 = m_getinput(m,'s');
                        if strcmp(var2,'d') == 1;
                            c(k1-length(delim):k2) = [];
                            delimindex = strfind(c,delim); % start locations of delim strings
                            ncoms = length(delimindex)-1; % number of comments remaning after one has been deleted
                            nreview = nreview-1;
                            continue
                        elseif strcmp(var2,' ') == 1 | strcmp(var2,'/') == 1;
                            nreview = nreview-1;
                            continue
                        else
                            
                            cstringnew = var2;
                            cold1 = c(1:k1-1);
                            cold2 = c(k2+1:end);
                            c = [cold1 cstringnew cold2];
                            delimindex = strfind(c,delim); % start locations of delim strings
                            ncoms = length(delimindex)-1; % number of comments remaning after one has been deleted
                            nreview = nreview-1;
                            continue
                        end
                    end
                    eflag2 = 1;
                end
            end
            
            % end of review, now add new comments
            
            m = 'Add new comments, / or return to end ';
%             fprintf(MEXEC_A.Mfidterm,'%s\n',m);
            
            eflag2 = 0;
            while eflag2 == 0
                var2 = m_getinput(m,'s');
                % if you want a comment consisting of space or slash you need to put something like '  ' or '/ '
                if strcmp(var2,' ') == 1;
                    eflag2 = 1;
                elseif strcmp(var2,'/') == 1;
                    eflag2 = 1;
                else
                    cstringnew = var2;
                    c = [c cstringnew delim];
                end
            end


            h.comment = c;
            m_write_header(ncfile,h);

            fprintf(MEXEC_A.Mfidterm,'%s\n\n',' ');
            if ~MEXEC_G.quiet; m_print_header(h); end
            m1 = ['Move on to next question ?'];
            m2 = ['type return or / to move on, 1 to repeat'];
            m = sprintf('%s\n',m1,m2);
            var3 = m_getinput(m,'s');
            if strcmp(var3,' ') == 1; eflag = 1; end
            if strcmp(var3,'/') == 1; eflag = 1; end
            if strcmp(var3,'1') == 1; eflag = 0; end
        end
    end

    if strcmp(var,'8') == 1 | strcmp(var,'0') == 1

        eflag = 0;
        while eflag == 0
            m0 = 'Variable names and units: ';
            m1 = ' Which option ? ';
            m2 = '-1 finished (default)';
            m3 = ' 0 all fields';
            m4 = ' varlist : just those variable numbers';
            m = sprintf('%s\n ',' ',m0,m1,m2,m3,m4);
            var = m_getinput(m,'s');
            if strcmp(var,' ') == 1; var = '-1'; end
            if strcmp(var,'/') == 1; var = '-1'; end
            if strcmp(var,'-1') == 1;
                eflag = 1;
                break;
            end
            if strcmp(var,'0') == 1; var = '/'; end % var is now the list of var numbers
            vlist = m_getvlist(var,h);
            vlist = unique(vlist); % sort the list

            for kl = 1:length(vlist)
                kvar = vlist(kl);
                eflag3 = 0;
                while eflag3 == 0
                    m1 = ['                                              ' h.fldnam{kvar} '     ' h.fldunt{kvar}];
                    m2 = ['Type new name  (return or / to keep as '  h.fldnam{kvar} ') : '];
                    m = sprintf('%s\n%s',m1,m2);
                    var2 = m_getinput(m,'s');
                    if strcmp(var2,' ') == 1;
                    elseif strcmp(var2,'/') == 1;
                    else
                        oldname = h.fldnam{kvar};
                        newname = m_check_nc_varname(var2);
                        kclash = strmatch(newname,h.fldnam,'exact');
                        if ~isempty(kclash)
                            if (length(kclash) == 1) & (kclash(1) == kvar)
                                m1 = 'Attempt to rename with the same name';
                                m2 = 'Use the slash option to leave name unchanged';
                                fprintf(MEXEC_A.Mfider,'%s\n',' ',m1,m2);
                            else
                                m1 = 'That name already exists in the file';
                                m2 = 'Choose another name';
                                fprintf(MEXEC_A.Mfider,'%s\n',' ',m1,m2);
                            end
                            continue
                        end
                        nc_varrename(ncfile.name,oldname,newname);
                        h = m_read_header(ncfile);
                    end

                    m2 = ['Type new units (return or / to keep as '  h.fldunt{kvar} ') : '];
                    var2 = m_getinput(m2,'s');
                    if strcmp(var2,' ') == 1;
                    elseif strcmp(var2,'/') == 1;
                    else
                        newunits = m_remove_outside_spaces(var2);
                        nc_attput(ncfile.name,h.fldnam{kvar},'units',newunits);
                        h = m_read_header(ncfile);
                    end
                    eflag3 = 1;
                end
            end
        end
    end
end

