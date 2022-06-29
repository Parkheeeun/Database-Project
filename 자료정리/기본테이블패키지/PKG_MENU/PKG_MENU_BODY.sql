create or replace NONEDITIONABLE PACKAGE BODY PKG_MENU AS

--1. SELECT
  PROCEDURE PROC_INS_MENU
(
    IN_STORE_ID        IN              VARCHAR2,
    IN_MENU_GRP_CODE   IN              VARCHAR2,
    IN_MENU_CODE1      IN              VARCHAR2,
    IN_MENU_CODE2      IN              VARCHAR2,
    IN_MENU_PRICE      IN              NUMBER,
    O_ERR_CODE         OUT             VARCHAR2,
    O_ERR_MSG          OUT             VARCHAR2
) AS

     V_NEW_MENU_ID        CHAR(6);
     V_MENU_CNT           NUMBER(3);
     V_STORE_CNT           NUMBER(3);
     EXCEPT_NOT_MENU      EXCEPTION;
     EXCEPT_NOT_STORE      EXCEPTION;
  BEGIN

--COMMON_TBL 에 등록된 메뉴가 있는지 확인
    SELECT DECODE(MAX(COM_ID), NULL, 0, 1)
    INTO V_MENU_CNT
    FROM
    (
        SELECT T1.GRP_ID, T1.COM_ID AS CA_COM_ID, T1.COM_VAL AS CA_COM_VAL, T2.COM_ID, T2.COM_VAL
        FROM COMMON_TBL T1, COMMON_TBL T2
        WHERE T1.GRP_ID = T2.GRP_ID AND T1.COM_ID = T2.PARENT_ID
        AND T1.GRP_ID = 'GRP001' AND T2.COM_LVL = 2
    )
    WHERE GRP_ID = IN_MENU_GRP_CODE
    AND CA_COM_ID = IN_MENU_CODE1 
    AND COM_ID = IN_MENU_CODE2
    ;
    
  -- STORE_TBL에서 STORE_ID 있는지 확인  
    SELECT DECODE(MAX(STORE_ID), NULL, 0, 1)
    INTO V_STORE_CNT
    FROM STORE_TBL
    WHERE STORE_ID = IN_STORE_ID
    ;
    
    IF V_MENU_CNT = 0 THEN
    -- COMMON_TBL에 메뉴가 없을시 예외처리 발생
        RAISE EXCEPT_NOT_MENU;
    ELSIF V_STORE_CNT = 0 THEN
    -- STORE_TBL에 STORE_ID가 없을시 예외처리 발생
        RAISE EXCEPT_NOT_STORE;
    END IF;
    
    -- 새로운 메뉴아이디 생성
    SELECT 'M' || TO_CHAR(TO_NUMBER(SUBSTR(MAX(MENU_ID),2,3))+1, 'FM000')
    INTO V_NEW_MENU_ID
    FROM MENU_TBL
    ;
    
    -- 메뉴 INSERT
   INSERT INTO MENU_TBL
   (
        MENU_ID,
        STORE_ID,
        MENU_GRP_CODE,
        MENU_CODE1,
        MENU_CODE2,
        MENU_PRICE
    )
    VALUES
    (
        V_NEW_MENU_ID,
        IN_STORE_ID,
        IN_MENU_GRP_CODE,
        IN_MENU_CODE1,
        IN_MENU_CODE2,
        IN_MENU_PRICE
    );
    
    --예외처리
    EXCEPTION
    
    -- COMMON_TBL NO_DATA
    WHEN EXCEPT_NOT_MENU THEN
    O_ERR_CODE := 'ERR100';
    O_ERR_MSG := '먼저 카테고리와 메뉴를 등록해 주세요';
    
    -- STORE_TBL NO_DATA
    WHEN EXCEPT_NOT_STORE THEN
    O_ERR_CODE := 'ERR101';
    O_ERR_MSG := '없는 STORE_ID 입니다';
    
    WHEN OTHERS THEN
    O_ERR_CODE := SQLCODE;
    O_ERR_MSG := SQLERRM;
   
  END PROC_INS_MENU;

--2. SELECT
  PROCEDURE PROC_SEL_MENU
(
    IN_MENU_ID         IN              VARCHAR2,
    IN_MENU_CA         IN              VARCHAR2,
    IN_MENU_NAME       IN              VARCHAR2,
    O_CURSOR           OUT             SYS_REFCURSOR,
    O_ERR_CODE         OUT             VARCHAR2,
    O_ERR_MSG          OUT             VARCHAR2
) AS
  BEGIN
   
   --A.MENU_TBL, B.COMMON_TBL JOIN 하여 메뉴 값(COM_VAL) 필드 가져온 TBL에서
   --MENU_ID, COMMON_TBL의 카테고리, 메뉴이름(COM_VAL) 검색
   OPEN O_CURSOR FOR
   SELECT * FROM 
   (
        SELECT A.MENU_ID, A.STORE_ID, A.MENU_GRP_CODE, A.MENU_CODE1, A.MENU_CODE2, B.CA_COM_VAL, B.COM_VAL, A.MENU_PRICE
        FROM MENU_TBL A,
        (
            SELECT T1.GRP_ID, T1.COM_ID AS CA_COM_ID, T1.COM_VAL AS CA_COM_VAL, T2.COM_ID, T2.COM_VAL
            FROM COMMON_TBL T1, COMMON_TBL T2
            WHERE T1.GRP_ID = T2.GRP_ID AND T1.COM_ID = T2.PARENT_ID
            AND T1.GRP_ID = 'GRP001' AND T2.COM_LVL = 2
        )B
        WHERE A.MENU_GRP_CODE = B.GRP_ID
        AND A.MENU_CODE1 = B.CA_COM_ID
        AND A.MENU_CODE2 = B.COM_ID
    )
    WHERE MENU_ID LIKE '%' || IN_MENU_ID || '%'
    AND CA_COM_VAL LIKE '%' || IN_MENU_CA || '%'
    AND COM_VAL LIKE '%' || IN_MENU_NAME || '%'
    ;
    
    --예외처리
    EXCEPTION
    WHEN OTHERS THEN
    O_ERR_CODE := SQLCODE;
    O_ERR_MSG := SQLERRM;
  
  END PROC_SEL_MENU;

--4. UPDATE
  PROCEDURE PROC_UP_MENU
(
    IN_MENU_ID         IN              CHAR,
    IN_STORE_ID        IN              VARCHAR2,
    IN_MENU_GRP_CODE   IN              VARCHAR2,
    IN_MENU_CODE1      IN              VARCHAR2,
    IN_MENU_CODE2      IN              VARCHAR2,
    IN_MENU_PRICE      IN              NUMBER,
    O_ERR_CODE         OUT             VARCHAR2,
    O_ERR_MSG          OUT             VARCHAR2
) AS
    V_MENU_CNT           NUMBER(3); --COMMON_TBL MENU 존재 확인
    V_STORE_CNT          NUMBER(3); --STORE_TBL STORE_ID 존재 확인
    EXCEPT_NOT_MENU      EXCEPTION; --COMMON_TBL MENU NO_DATA 예외처리
    EXCEPT_NOT_STORE     EXCEPTION; --STORE_TBL STORE_ID NO_DATA 예외처리
  BEGIN
    
    --COMMON_TBL 에 등록된 메뉴가 있는지 확인       
    SELECT DECODE(MAX(COM_ID), NULL, 0, 1)
    INTO V_MENU_CNT
    FROM
    (
        SELECT T1.GRP_ID, T1.COM_ID AS CA_COM_ID, T1.COM_VAL AS CA_COM_VAL, T2.COM_ID, T2.COM_VAL
        FROM COMMON_TBL T1, COMMON_TBL T2
        WHERE T1.GRP_ID = T2.GRP_ID AND T1.COM_ID = T2.PARENT_ID
        AND T1.GRP_ID = 'GRP001' AND T2.COM_LVL = 2
    )
    WHERE GRP_ID = IN_MENU_GRP_CODE
    AND CA_COM_ID = IN_MENU_CODE1 
    AND COM_ID = IN_MENU_CODE2
    ;
    
    --STORE_TBL에 등록된 STORE_ID 있는지 확인 
    SELECT DECODE(MAX(STORE_ID), NULL, 0, 1)
    INTO V_STORE_CNT
    FROM STORE_TBL
    WHERE STORE_ID = IN_STORE_ID
    ;
    
    IF V_MENU_CNT = 0 THEN
    -- COMMON_TBL에 메뉴가 없을시 예외처리 발생
        RAISE EXCEPT_NOT_MENU;
    ELSIF V_STORE_CNT = 0 THEN
    -- STORE_TBL에 STORE_ID가 없을시 예외처리 발생
        RAISE EXCEPT_NOT_STORE;
    END IF;
     --MENU_TBL 메뉴 업데이트      
      UPDATE MENU_TBL
      SET   STORE_ID = IN_STORE_ID,
            MENU_GRP_CODE = IN_MENU_GRP_CODE,
            MENU_CODE1 = IN_MENU_CODE1,
            MENU_CODE2 = IN_MENU_CODE2,
            MENU_PRICE = IN_MENU_PRICE
      WHERE MENU_ID = IN_MENU_ID
      ;
   
    EXCEPTION
    --COMMON_TBL NO_DATA 예외처리
    WHEN EXCEPT_NOT_MENU THEN
    O_ERR_CODE := 'ERR300';
    O_ERR_MSG := '먼저 카테고리와 메뉴를 등록해 주세요';
    --STORE_TBL STORE_ID NO_DATA 예외처리
    WHEN EXCEPT_NOT_STORE THEN
    O_ERR_CODE := 'ERR301';
    O_ERR_MSG := '없는 STORE_ID 입니다';
    
    WHEN OTHERS THEN
    O_ERR_CODE := SQLCODE;
    O_ERR_MSG := SQLERRM;


  END PROC_UP_MENU;

--4. DELETE
  PROCEDURE PROC_DEL_MENU
(
    IN_MENU_ID         IN              CHAR,
    O_ERR_CODE         OUT             VARCHAR2,
    O_ERR_MSG          OUT             VARCHAR2
) AS
     V_CNT               NUMBER(3);
     EXCEPT_NODATE       EXCEPTION;
  BEGIN
  
    SELECT DECODE(MAX(MENU_ID), NULL, 0, 1)
    INTO V_CNT
    FROM MENU_TBL
    WHERE MENU_ID = IN_MENU_ID;
  
    IF V_CNT = 0 THEN
       RAISE EXCEPT_NODATE;
    ELSE
       DELETE FROM MENU_TBL
       WHERE MENU_ID = IN_MENU_ID;
    END IF;
   
    EXCEPTION
    
    WHEN EXCEPT_NODATE THEN
    O_ERR_CODE := 'ERR400';
    O_ERR_MSG := '삭제할 데이터가 없습니다';
    
    WHEN OTHERS THEN
    O_ERR_CODE := SQLCODE;
    O_ERR_MSG := SQLERRM;
   
  END PROC_DEL_MENU;

END PKG_MENU;