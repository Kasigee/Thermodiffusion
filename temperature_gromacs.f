      program main
      implicit none
      integer i,j,k,l,m,n,nconstr,count_cat(10000,1),count_an(10000,1),
     & natom,Nstart,Nfinish,Npoints,nspecies,istart,iend,stepsize,
     & startline,stepsize2,nSOL,nT,nU,nCAT,nAN
      real*8 count_wat(100000,2)
      include 'maxima.inc'
      character*60 velofile,adummy
      character(len=10) atomname(10,99000),molname(10,99000)
      double precision velo(3,maxatm),zcoord(1,maxatm),
     & temperature,E_k,E_k_sum(100000,1),E_k_cold,
     & E_k_cold_sum(100000,1),E_k_hot,E_k_hot_sum(100000,1),
     & E_k_unres,E_k_unres_sum(100000,1),dof_u,dof_j
      real*8 velomax, dz, rnorm,atemp,velo_array(100000,2),vx2,
     & vy2,vz2,velo_mag,rKb,pi,tatom,v,f_maxwell,kB,
     & temperature_array(100000,6),R,amass2,amu,nmpstoms,
     & temperature_array2(100000,6),dof,dof_c,dof_h,
     & temperature_array_c(100000,6),temperature_array_h(100000,6),
     & temperature_array_u(100000,6),zmax,npart,Soret_coeff(100,1)
      parameter(rKb=3.16683D-6)
      parameter(pi=3.1415926535897932d0)
      parameter(R=8.314)
      parameter(kB=1.380649D-23)
      parameter(amu=1.660538921D-27)
      parameter(nmpstoms=1000)

      REAL :: start_time, end_time, elapsed_time
      CALL CPU_TIME(start_time)

      open(10,file='temperature.in')
      read(10,*) natom,nconstr,istart,iend
      read(10,*) nSOL,nT,nU,nCAT,nAN
      read(10,*) velofile
      read(10,*) Nstart,Nfinish,stepsize
      read(10,*) zmax,npart
      close(10)

      Npoints=Nfinish-Nstart
      dz=zmax/npart

      startline=(natom+3)*(Nstart-1)+1
      print *, startline
      stepsize2=(natom+3)*(stepsize-1)

      do i=1,npart
       do j=1,6
         temperature_array(i,j) = 0.000d0
         temperature_array_c(i,j) = 0.000d0
         temperature_array_h(i,j) = 0.000d0
         temperature_array_u(i,j) = 0.000d0
       enddo
      enddo

      do i=1,npart
       temperature_array(i,1) = dz * i
       temperature_array_c(i,1) = dz * i
       temperature_array_h(i,1) = dz * i
       temperature_array_u(i,1) = dz * i
c       print *, temperature_array(i,1)
      enddo


      open(10,file=velofile)
c      read(10,*) adummy
      do i=1,startline
        read(10,*) adummy
      end do
      do i=Nstart,Nfinish,stepsize
c        print *,i
c        read(10,*) adummy
        read(10,*) adummy
        do n=1,natom
c         read(10,*) atomname(2,n),atomname(1,n)
         if( ( n .lt. 10000 ) ) then
                read(10,*) molname(1,n),atomname(2,n),adummy,adummy,
     &   adummy,zcoord(1,n),velo(1,n),velo(2,n),velo(3,n)
c                if ( ( n .eq. 1 ) ) then
c                        print *,'atom',n,'step',i
c                end if
         else
                 read(10,*) molname(1,n),atomname(2,n),adummy,adummy,
     &          zcoord(1,n),velo(1,n),velo(2,n),velo(3,n)
         end if
         if((n.ge.istart).and.(n.le.iend)) then
c          print *, 'Velocities:',velo(2,n),velo(3,n),velo(4,n),
c     &    'mass:',atomname(2,n)
          vx2 = velo(1,n)*velo(1,n)
          vy2 = velo(2,n)*velo(2,n)
          vz2 = velo(3,n)*velo(3,n)
          velo_mag= sqrt(vx2 + vy2 +vz2)
          if( ( index(atomname(2,n),'NA') /= 0 ) ) then
                  amass2=22.99
c                  print *,amass2,'NA. atom number',n
          else if ( ( index(atomname(2,n),'HW') /= 0 ) ) then
                  amass2=1.008
c                  print *,amass2,'HW',n
          else if ( ( index(atomname( 2,n),'OW') /= 0 ) ) then
                  amass2=16.00
c                  print *,amass2,'OW. atom number',n
          else if ( ( index(atomname(2,n),'CL') /= 0 ) ) then
                  amass2=35.45
c                  print *,amass2,'CL'
          else
                  print *,'undefined mass, update',atomname(2,n),i
                  print *,zcoord(1,n),velo(1,n),velo(2,n),velo(3,n)
          end if
c          amass2=atomname(2,n)
c          print *, velo_mag*Apstoms
c          temperature=amass2*(velo_mag)/(3*R)
          if ( ( index(molname(1,n),'TS') /= 0 ) ) then
                  E_k_cold=(5D-1)*(amass2*amu)*(velo_mag*nmpstoms)**2
                  E_k_cold_sum(i,1) = E_k_cold_sum(i,1) + E_k_cold
          else if ( ( index(molname(1,n),'US') /= 0 ) ) then
                  E_k_hot=(5D-1)*(amass2*amu)*(velo_mag*nmpstoms)**2
                  E_k_hot_sum(i,1) = E_k_hot_sum(i,1) + E_k_hot
          else
                  E_k_unres=(5D-1)*(amass2*amu)*(velo_mag*nmpstoms)**2
                  E_k_unres_sum(i,1) = E_k_unres_sum(i,1) + E_k_unres
          end if
          E_k=(5D-1)*(amass2*amu)*(velo_mag*nmpstoms)**2
c          print *,'Kinetic E of atom',n,'is',E_k
c          temperature=amass2*amu*(velo_mag*nmpstoms)**2/((3*natom-3)*kB)
c          print *,'Temperature of atom', n, 'with z coord', zcoord(1,n),
c     &    'at timestep', i, 'is', temperature
          E_k_sum(i,1) = E_k_sum(i,1) + E_k
c          print *,'Total KE at atom', n, 'is',E_k_sum(i,1), 'Joules?'
          do j=1,npart
            if( ( zcoord(1,n) .ge. temperature_array(j-1,1) ) .and.
     &          ( zcoord(1,n) .lt. temperature_array(j,1)) ) then
               temperature_array(j,2) = temperature_array(j,2) + 1.d0
               temperature_array(j,3) = temperature_array(j,3)+1.d0*E_k
               if( ( index(molname(1,n),'NA') /= 0 ) ) then
c                  temperature_array(j,5) = temperature_array(j,5) + 1
                  count_cat(j,1) = count_cat(j,1) + 1
               else if ( ( index(molname(1,n),'CL') /= 0 ) ) then
c                  temperature_array(j,6) = temperature_array(j,6) + 1
                  count_an(j,1) =  count_an(j,1) +1
               else
                   count_wat(j,1) =  count_wat(j,1) +1
               end if
               if ( ( index(molname(1,n),'SOL') /= 0 ) .or.
     &              ( index(molname(1,n),'NA') /= 0 ) .or.
     &              ( index(molname(1,n),'CL') /= 0 ) ) then
                count_wat(j,2) =  count_wat(j,2) +1
                temperature_array(j,5) = temperature_array(j,5)+1.d0*E_k
               end if
            endif
          enddo
         endif
        enddo
c        print *, count_wat(j,1)
c        dof=3*natom-3
c        print *,dof
c        print *,'need to generalise the d.o.f. maths'
        dof_c=(3.d0*(nT*3)-3*nT)*(3*natom-nconstr-3)/(3*natom-nconstr)
        dof_h=(3.d0*nU*3-3*nU)*(3*natom-nconstr-3)/(3*natom-nconstr)
c         dof_u=dof-dof_c-dof_h
        dof_u=(3.d0*(nSOL*3+nCAT+nAN)-(nSOL*3+nCAT+nCAT))*
     & (3.d0*natom-nconstr-3)/(3*natom-nconstr)
c        dof_u=((3.d0*natom)-nconstr-3)/((3*natom)-nconstr)
        dof=dof_c+dof_h+dof_u
c        print *,'DOF',dof,dof_c,dof_h,dof_u,natom,nconstr
        temperature_array2(i,1)=(2*E_k_sum(i,1))/((dof)*kB)
        temperature_array_c(i,1)=(2*E_k_cold_sum(i,1))/((dof_c)*kB)
        temperature_array_h(i,1)=(2*E_k_hot_sum(i,1))/((dof_h)*kB)
        temperature_array_u(i,1)=(2*E_k_unres_sum(i,1))/((dof_u)*kB)
c        print *,'fix the degrees of freedom'
        read(10,*) adummy
        read(10,*) adummy
        if ( stepsize .gt. 1 ) then
         do l=1,stepsize2
          read(10,*) adummy
         end do
        end if
        print *,'Kinetic E =',E_k_sum(i,1)*6.022D23/1000,'kJ/mol ',
     & 'Temperature',temperature_array2(i,1),'K. Step',i
c        print *,'Kinetic E c =',E_k_cold_sum(i,1)*6.022D24/1000,
c     &  'kJ/mol ','Temperature',temperature_array_c(i,1),'K. Step',i
c        print *,'Kinetic E h =',E_k_hot_sum(i,1)*6.022D24/1000,
c     &  'kJ/mol ','Temperature',temperature_array_h(i,1),'K. Step',i
c        print *,'Kinetic E u =',E_k_unres_sum(i,1)*6.022D24/1000,
c     &  'kJ/mol ','Temperature',temperature_array_u(i,1),'K. Step',i
        if( mod(i,100) .eq. 0 ) then
              print *,'step',i,'of',Nfinish
        end if
      enddo
      close(10)

      print *,'need to generalise the d.o.f. maths'
      open(60, file = 'temp_per_z.dat', status='unknown')
      do i=1,npart
c        print *, temperature_array(i,1),temperature_array(i,3)
c       print *, temperature_array(i,1)
       dof_j=(3.d0*temperature_array(i,2)-temperature_array(i,2))*
     & (3*natom-nconstr-3)/(3*natom-nconstr)
       dof_u=((3.d0*count_wat(i,2)-count_wat(i,2))*
     & (3*natom-nconstr-3)/(3*natom-nconstr))
c       print *,temperature_array(i,2),dof_j
       temperature_array(i,4) = (2.d0*temperature_array(i,3))/
     & ((dof_j)*kB)
        temperature_array(i,6) = (2.d0*temperature_array(i,5))/
     & ((dof_u)*kB)
c        Sorret_coeff(i,1) = -1 /
c (count...(1-count...))*(count..-1-count...+1)/(temp...-1-temp...+1)
       print 200, temperature_array(i,1),temperature_array(i,4),
     & temperature_array(i,6),count_cat(i,1),count_an(i,1),
     & count_wat(i,1),count_wat(i,2)
200    format(f10.2,f10.2,F10.2,i10,i10,f10.0,f10.0)
       write(60,'(f10.2,f10.2,F10.2,i10,i10,f10.0,f10.0)')
     & temperature_array(i,1),temperature_array(i,4),
     & temperature_array(i,6),count_cat(i,1),count_an(i,1),
     & count_wat(i,1),count_wat(i,2)
      enddo
      close(60)
      print *,"crash before here?"

      CALL CPU_TIME(end_time)
      elapsed_time = end_time - start_time
      WRITE(*,*) "Elapsed time:", elapsed_time, "sec"

      end
