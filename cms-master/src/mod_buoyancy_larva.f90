!****************************************************************************
!* System: Connectivity Modeling System (CMS)                               *
!* File : mod_buoyancy_larva.f90                                            *
!* Last Modified: 2016-04-08                                                *
!* Code contributors: Claire B. Paris, Judith Helgers, Ana Carolina Vaz     * 
!*                                                                          *
!* Copyright (C) 2011, University of Miami                                  *
!*                                                                          *
!* This program is free software: you can redistribute it and/or modify     *
!* it under the terms of the GNU Lesser General Public License as published *
!* by the Free Software Foundation, either version 3 of the License, or     *
!*(at your option) any later version.                                       *
!*                                                                          *
!* This program is distributed in the hope that it will be useful,          *
!* but WITHOUT ANY WARRANTY; without even the implied warranty of           *
!* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
!* See the Lesser GNU General Public License for more details.              *
!*                                                                          *
!* You should have received a copy of the GNU Lesser General                *
!* Public License along with this program.                                  *
!* If not, see <http://www.gnu.org/licenses/>.                              *
!****************************************************************************


MODULE mod_buoyancy

USE mod_kinds
USE constants
USE mod_iounits

IMPLICIT NONE

 real (kind = real_kind), allocatable, save  :: MinDens(:), MaxDens(:), MinDiam(:), MaxDiam(:)
 integer (kind = int8_kind), allocatable, save  :: buoyancyTime(:)
 integer (kind=int_kind), save               :: numBuoyancy

CONTAINS

!**************************************************************
!Calculate buoyancy component for larva
!Equation (2), (3) and (4) from Zheng and Yapa(2000)
subroutine get_buoyancy(dens_water, temp_water, diam_part, dens_part, w2)

real(kind=real_kind), intent(in)  :: &
     dens_water, temp_water, diam_part, dens_part
real(kind=real_kind), intent(out) :: w2

real(kind=real_kind) :: viscosity

 viscosity = 1.88e-3 - (temp_water*4.e-5) 

 !Formula of Stokes  
  w2 = (9.8*(diam_part*diam_part)*(dens_part-dens_water))/(18.*viscosity)
  
END SUBROUTINE get_buoyancy

!**************************************************************
 subroutine load_buoyancy(buoyancyFilename)

 character(len = *), intent(in) :: buoyancyFilename
 integer (kind=int_kind) :: i,j, iunit
 real (kind = real_kind) :: cum
 logical (kind=log_kind) :: file_exists
 !open file
 call get_unit(iunit)
 INQUIRE(FILE=trim(buoyancyFilename), EXIST=file_exists)
 IF (file_exists) THEN
  OPEN(UNIT=iunit,FILE=trim(buoyancyFilename),STATUS="old")
 ELSE
  print *, "Error: File ", trim(buoyancyFilename)," does not exist"
  stop
 ENDIF
!read file
 read(iunit, *) numBuoyancy
! numBuoyancy is the number of different buoyancy to be calculated
! buoyancyTime time steps to change attributes
! buoyancyDens densities for buoyancy
! buoyancyDiam diameters for buoyancy
 allocate(buoyancyTime(numBuoyancy))
 read(iunit,*) (buoyancyTime(i), i = 1, numBuoyancy) 
 allocate(MinDens(numBuoyancy)) 
 read(iunit,*) (MinDens(i), i = 1, numBuoyancy) 
 allocate(MaxDens(numBuoyancy)) 
 read(iunit,*) (MaxDens(i), i = 1, numBuoyancy)  
 allocate(MinDiam(numBuoyancy)) 
 read(iunit,*) (MinDiam(i), i = 1, numBuoyancy)   
 allocate(MaxDiam(numBuoyancy)) 
 read(iunit,*) (MaxDiam(i), i = 1, numBuoyancy)    
!close file
 call release_unit(iunit)
 END SUBROUTINE load_buoyancy
 
END MODULE mod_buoyancy
