REM $Header: peptufxu.sql 115.1 2002/10/25 16:12:07 asahay noship $
REM dbdrv: none
REM
REM File Information
REM ================
REM Creates person type usage information for persons missed during upgrade
REM It deletes any ptu records from person_type_usages_f table for those 
REM person and reconstructs them from the person level information.
REM This file will take person_id as the input.
REM
REM Note :- If a user is changed from composite person type flavour
REM to another. We still create a date track PTU entry. This will ensure
REM that the  users can change that to whichever base flavors they want
REM
REM Change List
REM ===========
REM Version Date        Author     Comment
REM -------+-----------+----------+-----------------------------------------------
REM 115.0   10-JUL-2002 AxSahay    Created
REM 115.1   25-OCT-2002 AxSahay    Added check for CoreHR Person Types
REM
REM ==============================================================================

WHENEVER OSERROR EXIT FAILURE ROLLBACK
WHENEVER SQLERROR EXIT FAILURE ROLLBACK
SET VERIFY OFF

define x_person_id = &1

DECLARE
--
--
  TYPE t_person_type_ids IS TABLE OF per_person_types.person_type_id%TYPE;

  l_data_migrator_mode 	    varchar2(30);

-- -------------------------------------------------------------------------------
-- Returns a table of simple types corresponding to the composite person types
-- specified.
--
-- If the person is an Applicant (APL, APL_EX_APL, EMP_APL or EX_EMP_APL) the 
-- returned table includes an APL person type identifier. If the person is an
-- Employee (EMP or EMP_APL) the returned table includes an EMP person type
-- identifier. If the person is an Ex-applicant (EX_APL) the returned table
-- includes an EX_APL person type identifier. If the person is an Ex-employee
-- (EX_EMP or EX_EMP_APL) the returned table includes an EX_EMP person type
-- identifier.
--
-- If the person was an Applicant (APL, APL_EX_APL, EMP_APL or EX_EMP_APL) and is
-- now an Employee (EMP) or an Ex-employee (EX_EMP) the returned table includes
-- an EX_APL person type identifier.
--
FUNCTION get_ptu_person_type_ids
  (p_person_type_id               IN     per_person_types.person_type_id%TYPE
  ,p_old_person_type_id           IN     per_person_types.person_type_id%TYPE 
  )
RETURN t_person_type_ids
IS
  --
  -- If the composite type is actually a simple type (APL, EMP, EX_APL or EX_EMP)
  -- just return it.
  -- If the composite type is a true composite type (APL_EX_APL, EMP_APL or
  -- EX_EMP_APL) return the specified simple types in the upgrade table, if
  -- defined, or the associated simple default types for the business group, if
  -- not.
  -- If the composite type is an Applicant type (APL, APL_EX_APL, EMP_APL or 
  -- EX_EMP_APL) and the previous type is EMP or EX_EMP return the default EX_APL
  -- type for the business group.
  --
  CURSOR csr_person_type_usages
    (p_person_type_id         IN     per_person_types.person_type_id%TYPE
    ,p_old_person_type_id     IN     per_person_types.person_type_id%TYPE
    )
  IS
    SELECT ppt.person_type_id
      FROM per_person_types ppt
     WHERE ppt.system_person_type IN ('APL','EMP','EX_APL','EX_EMP','OTHER')
       AND ppt.person_type_id = p_person_type_id
     UNION
    SELECT dft.person_type_id
      FROM per_person_types dft
          ,per_person_types ppt
     WHERE (  (   dft.system_person_type = 'APL'
              AND ppt.system_person_type IN ('APL_EX_APL','EMP_APL','EX_EMP_APL'))
           OR (   dft.system_person_type = 'EMP'
              AND ppt.system_person_type IN ('EMP_APL'))
           OR (   dft.system_person_type = 'EX_EMP'
              AND ppt.system_person_type IN ('EX_EMP_APL')) )
       AND dft.default_flag = 'Y'
       AND dft.active_flag = 'Y'
       AND dft.business_group_id = ppt.business_group_id
       AND ppt.person_type_id = p_person_type_id
     UNION
    SELECT dft.person_type_id
      FROM per_person_types dft
          ,per_person_types npt
          ,per_person_types opt
     WHERE (   dft.system_person_type = 'EX_APL'
           AND npt.system_person_type IN ('EMP','EX_EMP')
           AND opt.system_person_type IN ('APL','APL_EX_APL','EMP_APL','EX_EMP_APL') )
       AND dft.default_flag = 'Y'
       AND dft.active_flag = 'Y'
       AND dft.business_group_id = npt.business_group_id
       AND dft.business_group_id = opt.business_group_id 
       AND npt.person_type_id = p_person_type_id
       AND opt.person_type_id = p_old_person_type_id;
  --
  tbl_person_type_ids            t_person_type_ids;
  --
BEGIN
  --
  hr_utility.set_location('Inside get_ptu_person_type_ids procedure',1);
  --
  OPEN csr_person_type_usages
    (p_person_type_id               => p_person_type_id
    ,p_old_person_type_id           => p_old_person_type_id
    );
  FETCH csr_person_type_usages BULK COLLECT INTO tbl_person_type_ids;
  CLOSE csr_person_type_usages;
  --
  RETURN tbl_person_type_ids;
  --
  hr_utility.set_location('Leaving get_ptu_person_type_ids procedure',1);
  --
END get_ptu_person_type_ids;
--
-- -------------------------------------------------------------------------------
--
-- Creates new person type usage records for person_id passed in 
-- throughout time.
--
PROCEDURE create_person_type_usages(p_person_id NUMBER)
IS
  --
  CURSOR csr_people
  IS
    SELECT per.person_type_id
          ,per.effective_start_date
          ,ppt.system_person_type
      FROM per_person_types ppt
          ,per_all_people_f per
     WHERE ppt.person_type_id = per.person_type_id
       AND per.person_id = p_person_id
  ORDER BY per.person_id
          ,per.effective_start_date;
  --
  c_null_person                  CONSTANT csr_people%ROWTYPE := NULL;
  l_person                       csr_people%ROWTYPE;
  l_old_person                   csr_people%ROWTYPE;
  l_effective_start_date         per_all_people_f.effective_start_date%TYPE;
  l_person_type_id               per_all_people_f.person_type_id%TYPE;
  tbl_person_type_ids            t_person_type_ids;
  l_index_number		 NUMBER;

  --
BEGIN
  --
  hr_utility.set_location('Inside create_person_type_usages procedure',1);
  OPEN csr_people;
  LOOP
    --
    FETCH csr_people INTO l_person;
    EXIT WHEN csr_people%NOTFOUND;
    --
    --
    IF (  l_person.person_type_id <> NVL(l_old_person.person_type_id,hr_api.g_number) )
    THEN
      tbl_person_type_ids := get_ptu_person_type_ids
        (p_person_type_id               => l_person.person_type_id
        ,p_old_person_type_id           => l_old_person.person_type_id
        );
      l_index_number := tbl_person_type_ids.FIRST;
      WHILE (l_index_number IS NOT NULL)
      LOOP
        hr_utility.set_location('Person id : '||to_char(p_person_id),25);
        hr_utility.set_location('Eff Date : '||to_char(l_person.effective_start_date,'DD-MON-YYYY'),25);
        hr_utility.set_location('Per Type id : '||to_char(tbl_person_type_ids(l_index_number)),25);
        hr_per_type_usage_internal.maintain_person_type_usage
          (p_effective_date               => l_person.effective_start_date
          ,p_person_id                    => p_person_id
          ,p_person_type_id               => tbl_person_type_ids(l_index_number)
          ,p_datetrack_update_mode        => hr_api.g_update
          );
        l_index_number := tbl_person_type_ids.NEXT(l_index_number);
      END LOOP;

    END IF;
    --
    l_old_person := l_person;
    --
  END LOOP;
  CLOSE csr_people;
  --
  COMMIT;
  --
  hr_utility.set_location('Leaving create_person_type_usages procedure',1);
  --
END create_person_type_usages;
--
-- -------------------------------------------------------------------------------
  --
BEGIN
  --
    l_data_migrator_mode := hr_general.g_data_migrator_mode;
    hr_general.g_data_migrator_mode := 'P';

  hr_utility.set_location('Delete from per_person_type_usages_f.',5);
    --

        DELETE
        FROM per_person_type_usages_f ptu
        WHERE ptu.person_id = &x_person_id
	and   ptu.person_type_id IN
           (SELECT ppt.person_type_id
            FROM per_person_types ppt
            WHERE ppt.system_person_type IN ('APL','APL_EX_APL','EMP','EMP_APL'
                                             ,'EX_APL','EX_EMP','EX_EMP_APL'
                                             ,'OTHER'));
    --
     hr_utility.set_location('Deleted from per_person_type_usages_f.',10);
    -- 
       create_person_type_usages(&x_person_id);
    --
  --
  hr_utility.set_location('End',20);

    hr_general.g_data_migrator_mode := l_data_migrator_mode;
  --
END;  -- person_type_usages_fix;
/
--
-- -------------------------------------------------------------------------------
COMMIT;
EXIT;
