create or replace NONEDITIONABLE PACKAGE BODY PKG_STORE AS
   --INSERT 시작
  PROCEDURE PROC_INS_STORE
   (
        IN_STORE_CA_GRP      IN  VARCHAR2,
        IN_STORE_CA_COM      IN  VARCHAR2,
        IN_STORE_NAME        IN  VARCHAR2,
        IN_STORE_ADDR_GRP    IN  VARCHAR2,
        IN_STORE_ADDR        IN  VARCHAR2,
        IN_STORE_ADDR2       IN  VARCHAR2,
        IN_STORE_ADDR3       IN  VARCHAR2,
        IN_STORE_TEL         IN  VARCHAR2,
        IN_OPEN_TIME         IN  VARCHAR2,
        IN_CLOSE_TIME        IN  VARCHAR2,
        IN_MIN_PRICE         IN  NUMBER,
        IN_STORE_SCORE       IN  NUMBER,
        O_ERRCODE            OUT VARCHAR2,
        O_ERRMSG             OUT VARCHAR2
   ) 
   AS
       V_NEW_STORE_ID     VARCHAR2(6);
       NOT_STORE_CA_GRP   EXCEPTION;
       NOT_STORE_ADDR_GRP EXCEPTION;
   
  BEGIN
    SELECT 'ST' || TO_CHAR(TO_NUMBER(SUBSTR(NVL(MAX(STORE_ID),'ST0000'),3,4))+1,'FM0000')
    INTO V_NEW_STORE_ID
    FROM STORE_TBL;
    
    IF IN_STORE_CA_GRP !='GRP001' THEN
    RAISE NOT_STORE_CA_GRP;
    END IF;
    
    IF IN_STORE_ADDR_GRP !='GRP002' THEN
    RAISE NOT_STORE_ADDR_GRP;
    END IF;
    
    
    
    INSERT INTO 
            STORE_TBL
            (
            STORE_ID ,
            STORE_CA_GRP,
            STORE_CA_COM,
            STORE_NAME,
            STORE_ADDR_GRP,
            STORE_ADDR,
            STORE_ADDR2,
            STORE_ADDR3,
            STORE_TEL,
            OPEN_TIME, 
            CLOSE_TIME,
            MIN_PRICE, 
            STORE_SCORE
            )
            VALUES
            (
            V_NEW_STORE_ID,
            IN_STORE_CA_GRP,
            IN_STORE_CA_COM,
            IN_STORE_NAME,
            IN_STORE_ADDR_GRP,
            IN_STORE_ADDR,
            IN_STORE_ADDR2,
            IN_STORE_ADDR3,
            IN_STORE_TEL,
            IN_OPEN_TIME,
            IN_CLOSE_TIME,
            IN_MIN_PRICE,
            IN_STORE_SCORE
            ); 
            
    EXCEPTION
    WHEN NOT_STORE_CA_GRP THEN
        O_ERRCODE := 'ERRGRP1';
        O_ERRMSG  := '가게카테고리가 아닙니다';
        ROLLBACK;
    
    WHEN NOT_STORE_ADDR_GRP THEN
        O_ERRCODE := 'ERRGRP2';
        O_ERRMSG  := '지역코드가 아닙니다';
        ROLLBACK;
    
    WHEN OTHERS THEN
        O_ERRCODE := SQLCODE;
        O_ERRMSG  := SQLERRM;
        ROLLBACK;
    
  END PROC_INS_STORE;
  
  --INSERT 끝
  
  --SELECT 시작
     PROCEDURE PROC_SEL_STORE
   (   
      IN_STORE_ID   IN  VARCHAR2,
      IN_STORE_NAME IN  VARCHAR2,
      O_CURSOR      OUT SYS_REFCURSOR,
      O_ERRCODE     OUT VARCHAR2,
      O_ERRMSG      OUT VARCHAR2
   )
   AS
     V_CHK_COUNT     NUMBER(2);
     NOT_SEL_CONTENT EXCEPTION;
     
   BEGIN
   /*
    SELECT COUNT(*)
    INTO V_CHK_COUNT
    FROM STORE_TBL
    WHERE STORE_ID LIKE '%' || IN_STORE_ID ||'%'
    AND STORE_NAME LIKE '%' || IN_STORE_NAME ||'%'
    ;
    
    IF V_CHK_COUNT=0 THEN
    RAISE NOT_SEL_CONTENT;
    END IF;
   */
    OPEN O_CURSOR FOR
    SELECT * FROM STORE_TBL
    WHERE STORE_ID   LIKE '%' || IN_STORE_ID   || '%'
    AND  STORE_NAME LIKE '%' || IN_STORE_NAME || '%'
    ;
    
    
    EXCEPTION
    /*
    WHEN NOT_SEL_CONTENT THEN
    O_ERRCODE :='ERR22';
    O_ERRMSG := '값이 없습니다';*/
    
    WHEN OTHERS THEN
    O_ERRCODE:= SQLCODE;
    O_ERRMSG:=SQLERRM;
    
   END PROC_SEL_STORE;
  
  --SELECT 끝
  
  --UPDATE 시작
     PROCEDURE PROC_UP_STORE
   (
        IN_STORE_ID          IN  VARCHAR2,
        IN_STORE_CA_GRP      IN  VARCHAR2,
        IN_STORE_CA_COM      IN  VARCHAR2,
        IN_STORE_NAME        IN  VARCHAR2,
        IN_STORE_ADDR_GRP    IN  VARCHAR2,
        IN_STORE_ADDR        IN  VARCHAR2,
        IN_STORE_ADDR2       IN  VARCHAR2,
        IN_STORE_ADDR3       IN  VARCHAR2,
        IN_STORE_TEL         IN  VARCHAR2,
        IN_OPEN_TIME         IN  VARCHAR2,
        IN_CLOSE_TIME        IN  VARCHAR2,
        IN_MIN_PRICE         IN  NUMBER,
        IN_STORE_SCORE       IN  NUMBER,
        O_ERRCODE            OUT VARCHAR2,
        O_ERRMSG             OUT VARCHAR2
     
   )
   
   AS
    NOT_STORE_CA_GRP EXCEPTION;
    NOT_STORE_ADDR_GRP EXCEPTION;
   BEGIN
    IF IN_STORE_CA_GRP !='GRP001' THEN
    RAISE NOT_STORE_CA_GRP;
    END IF;
    
    IF IN_STORE_ADDR_GRP !='GRP002' THEN
    RAISE NOT_STORE_ADDR_GRP;
    END IF;
   
    UPDATE STORE_TBL 
    SET 
            STORE_CA_GRP =IN_STORE_CA_GRP,
            STORE_CA_COM=IN_STORE_CA_COM,
            STORE_NAME=IN_STORE_NAME,
            STORE_ADDR_GRP = IN_STORE_ADDR_GRP,
            STORE_ADDR =IN_STORE_ADDR,
            STORE_ADDR2 =IN_STORE_ADDR2,
            STORE_ADDR3 =IN_STORE_ADDR3,
            STORE_TEL =IN_STORE_TEL,
            OPEN_TIME =IN_OPEN_TIME, 
            CLOSE_TIME =IN_CLOSE_TIME,
            MIN_PRICE =IN_MIN_PRICE, 
            STORE_SCORE= IN_STORE_SCORE
        WHERE STORE_ID =IN_STORE_ID
        ;
        
        EXCEPTION
        WHEN NOT_STORE_CA_GRP THEN
        O_ERRCODE:= 'ERR1';
        O_ERRMSG:= 'GRP001외에는 불가합니다';
        ROLLBACK;
        
        WHEN NOT_STORE_ADDR_GRP THEN
        O_ERRCODE := 'ERR2';
        O_ERRMSG:= 'GRP002 외에는 불가합니다';
        ROLLBACK;
        
        WHEN OTHERS THEN
        O_ERRCODE :=SQLCODE;
        O_ERRMSG :=SQLERRM;
    
    
   END PROC_UP_STORE;
  --UPDATE 끝
  
  --DELETE 시작
   PROCEDURE PROC_DEL_STORE
   (
        IN_STORE_ID IN VARCHAR2,
        O_ERRCODE   OUT VARCHAR2,
        O_ERRMSG    OUT VARCHAR2
   )
   AS
    V_COUNT_ST  NUMBER(1);
    NOT_STORE_ID EXCEPTION; 
   BEGIN
    
    SELECT COUNT(*)
    INTO V_COUNT_ST
    FROM STORE_TBL
    WHERE STORE_ID = IN_STORE_ID
    ;
    
    
    IF V_COUNT_ST=0 THEN
    RAISE NOT_STORE_ID;
    END IF;
   
    DELETE STORE_TBL
    WHERE STORE_ID = IN_STORE_ID
    ;
    
    
    EXCEPTION
    WHEN NOT_STORE_ID THEN
    O_ERRCODE := 'ERR010';
    O_ERRMSG := '없는 가게입니다';
    
    WHEN OTHERS THEN
        O_ERRCODE := SQLCODE;
        O_ERRMSG  := SQLERRM;
        ROLLBACK;
   END PROC_DEL_STORE;

 --DELETE 끝
  
  

END PKG_STORE;