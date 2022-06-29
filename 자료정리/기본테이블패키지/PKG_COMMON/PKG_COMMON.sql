CREATE OR REPLACE PACKAGE PKG_COMMON AS 

    PROCEDURE PROC_INS_COMMON
        (
            IN_GRP_ID          IN      VARCHAR2,
            IN_COM_VAL         IN      VARCHAR2,
            IN_COM_LVL         IN      NUMBER,
            IN_PARENT_ID       IN      VARCHAR2,
            IN_EXCEPT_VAL1     IN      VARCHAR2,
            IN_EXCEPT_VAL2     IN      VARCHAR2,
            IN_EXCEPT_VAL3     IN      VARCHAR2,
            O_ERRCODE          OUT     VARCHAR2,
            O_ERRMSG           OUT     VARCHAR2
        );
        
    PROCEDURE PROC_SEL_COMMON
    (
            IN_GRP_ID       IN      CHAR,
            IN_COM_VAL      IN      VARCHAR2,
            O_ERRCODE       OUT     VARCHAR2,
            O_ERRMSG        OUT     VARCHAR2,
            O_CUR           OUT     SYS_REFCURSOR               
    );
        
    PROCEDURE PROC_UP_COMMON
        (
            IN_GRP_ID          IN      CHAR,
            IN_COM_ID          IN      CHAR,
            IN_COM_VAL         IN      VARCHAR2,
            IN_EXCEPT_VAL1     IN      VARCHAR2,
            O_ERRCODE          OUT     VARCHAR2,
            O_ERRMSG           OUT     VARCHAR2
        );
    
    PROCEDURE   PROC_DEL_COMMON
        (
            IN_GRP_ID       IN      CHAR,
            IN_COM_ID       IN      CHAR,
            O_ERRCODE       OUT     VARCHAR2,
            O_ERRMSG        OUT     VARCHAR2
        );

END PKG_COMMON;
/


CREATE OR REPLACE PACKAGE BODY PKG_COMMON AS

  PROCEDURE PROC_INS_COMMON
        (
            IN_GRP_ID          IN      VARCHAR2,
            IN_COM_VAL         IN      VARCHAR2,
            IN_COM_LVL         IN      NUMBER,
            IN_PARENT_ID       IN      VARCHAR2,
            IN_EXCEPT_VAL1     IN      VARCHAR2,
            IN_EXCEPT_VAL2     IN      VARCHAR2,
            IN_EXCEPT_VAL3     IN      VARCHAR2,
            O_ERRCODE          OUT     VARCHAR2,
            O_ERRMSG           OUT     VARCHAR2
        ) AS
        V_NEW_COM_ID    CHAR(6);
  BEGIN

    SELECT 'COM' || TO_CHAR(TO_NUMBER(SUBSTR(MAX(COM_ID),4,3)) +1,'FM000')
    INTO V_NEW_COM_ID
    FROM COMMON_TBL
    WHERE PARENT_ID != 'ROOT' AND GRP_ID=IN_GRP_ID AND COM_LVL=IN_COM_LVL;

    
    INSERT INTO COMMON_TBL(GRP_ID,COM_ID,COM_VAL,COM_LVL,PARENT_ID,EXCEPT_VAL1,EXCEPT_VAL2,EXCEPT_VAL3)
    VALUES (IN_GRP_ID,V_NEW_COM_ID,IN_COM_VAL,IN_COM_LVL,IN_PARENT_ID,IN_EXCEPT_VAL1,IN_EXCEPT_VAL2,IN_EXCEPT_VAL3);
    
    EXCEPTION WHEN OTHERS THEN
    O_ERRCODE:=SQLCODE;
    O_ERRMSG:=SQLERRM;
    
  END PROC_INS_COMMON;

  PROCEDURE PROC_SEL_COMMON
    (
            IN_GRP_ID       IN      CHAR,
            IN_COM_VAL      IN      VARCHAR2,
            O_ERRCODE       OUT     VARCHAR2,
            O_ERRMSG        OUT     VARCHAR2,
            O_CUR           OUT     SYS_REFCURSOR           
    ) AS
  BEGIN
    OPEN O_CUR FOR
    SELECT * FROM COMMON_TBL
    WHERE COM_VAL LIKE '%' || IN_COM_VAL || '%'
    START WITH PARENT_ID='ROOT' AND GRP_ID=IN_GRP_ID
    CONNECT BY PRIOR COM_ID=PARENT_ID AND GRP_ID=IN_GRP_ID;
    
    EXCEPTION WHEN OTHERS THEN
    O_ERRCODE:=SQLCODE;
    O_ERRMSG:=SQLERRM;
    
  END PROC_SEL_COMMON;

  PROCEDURE PROC_UP_COMMON
        (
            IN_GRP_ID          IN      CHAR,
            IN_COM_ID          IN      CHAR,
            IN_COM_VAL         IN      VARCHAR2,
            IN_EXCEPT_VAL1     IN      VARCHAR2,
            O_ERRCODE       OUT     VARCHAR2,
            O_ERRMSG        OUT     VARCHAR2
        ) AS
  BEGIN
    
    UPDATE COMMON_TBL
    SET EXCEPT_VAL1=IN_EXCEPT_VAL1,
        COM_VAL=IN_COM_VAL
    WHERE GRP_ID=IN_GRP_ID
    AND COM_ID=IN_COM_ID;
    
    EXCEPTION WHEN OTHERS THEN
    O_ERRCODE:=SQLCODE;
    O_ERRMSG:=SQLERRM;

  END PROC_UP_COMMON;

  PROCEDURE   PROC_DEL_COMMON
        (
            IN_GRP_ID       IN      CHAR,
            IN_COM_ID       IN      CHAR,
            O_ERRCODE       OUT     VARCHAR2,
            O_ERRMSG        OUT     VARCHAR2
        ) AS
        
        V_COMID_CNT     NUMBER(1);
        
        COMMON_DEL_EXCEPTION    EXCEPTION;
  BEGIN
    
    SELECT COUNT(*) INTO V_COMID_CNT
    FROM COMMON_TBL
    WHERE COM_ID=IN_COM_ID AND GRP_ID=IN_GRP_ID;
    
    IF V_COMID_CNT = 0 THEN
        RAISE COMMON_DEL_EXCEPTION;
    ELSE
        DELETE FROM COMMON_TBL 
        WHERE COM_ID IN 
        (
        SELECT COM_ID FROM COMMON_TBL
        WHERE COM_VAL LIKE '%%'
        AND COM_ID LIKE '%%'
        AND COM_LVL LIKE '%%'
        START WITH COM_ID=IN_COM_ID AND GRP_ID=IN_GRP_ID
        CONNECT BY PRIOR COM_ID=PARENT_ID AND GRP_ID=IN_GRP_ID
        )
        AND GRP_ID=IN_GRP_ID;
    END IF;
    
    EXCEPTION
    WHEN COMMON_DEL_EXCEPTION THEN
    O_ERRCODE := 'ERROR001';
    O_ERRMSG := 'NO DATA';
    
    WHEN OTHERS THEN
    O_ERRCODE:=SQLCODE;
    O_ERRMSG:=SQLERRM;
    
  END PROC_DEL_COMMON;

END PKG_COMMON;
/
