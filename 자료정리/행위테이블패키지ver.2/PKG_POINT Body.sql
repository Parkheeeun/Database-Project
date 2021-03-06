create or replace NONEDITIONABLE PACKAGE BODY PKG_POINT AS

  --포인트 등록 프로시저
  PROCEDURE PROC_INS_POINT
  (
    IN_ORDER_ID     IN VARCHAR2,
    IN_POINT_COM_ID IN VARCHAR2,
    O_ERRCODE       OUT VARCHAR2,
    O_ERRMSG        OUT VARCHAR2
  ) AS
    
    V_NEW_POINT_IDX     NUMBER;
    V_POINT_USE         CHAR(1);
    V_POINT_COM_VAL     NUMBER;
    
    V_GET_POINT_SCORE   NUMBER;   
    
    V_TOTAL_PRICE       NUMBER;
    V_USER_ID           CHAR(6);
    
    NO_GET_POINT_EXCEPT EXCEPTION;
  
  BEGIN
    
    --포인트IDX 부여
    SELECT TO_NUMBER(NVL(MAX(POINT_IDX), 0)) + 1
    INTO V_NEW_POINT_IDX
    FROM EARN_POINT_HISTORY_TBL;
    
    --포인트 사용여부 확인
    SELECT USE_POINT
    INTO V_POINT_USE
    FROM ORDER_LIST_TBL
    WHERE ORDER_ID = IN_ORDER_ID;
    
    --현재 포인트 적립율 확인(0.05)
    SELECT COM_VAL
    INTO V_POINT_COM_VAL
    FROM COMMON_TBL
    WHERE GRP_ID = 'GRP005'
    AND COM_ID = IN_POINT_COM_ID;
    
    --총 음식주문금액 확인
    SELECT TOTAL_PRICE
    INTO V_TOTAL_PRICE
    FROM ORDER_LIST_TBL
    WHERE ORDER_ID = IN_ORDER_ID;
    
    --주문한 유저 확인
    SELECT MAX(T2.USER_ID)
    INTO V_USER_ID
    FROM ORDER_LIST_TBL T1, ORDER_TBL T2
    WHERE T1.ORDER_ID = T2.ORDER_ID
    AND T1.ORDER_ID = IN_ORDER_ID;
    
    V_GET_POINT_SCORE := V_POINT_COM_VAL * V_TOTAL_PRICE;
    
    IF V_POINT_USE = 'N' THEN
        INSERT INTO EARN_POINT_HISTORY_TBL(POINT_IDX,USER_ID,ORDER_ID,P_GRP_ID,P_COM_ID,EARN_POINT)
        VALUES(V_NEW_POINT_IDX,V_USER_ID,IN_ORDER_ID,'GRP005',IN_POINT_COM_ID,V_GET_POINT_SCORE);
    ELSIF V_POINT_USE = 'Y' THEN
        RAISE NO_GET_POINT_EXCEPT;
        INSERT INTO EARN_POINT_HISTORY_TBL(POINT_IDX,USER_ID,ORDER_ID,P_GRP_ID,P_COM_ID,EARN_POINT) 
        VALUES(V_NEW_POINT_IDX,V_USER_ID,IN_ORDER_ID,'GRP005',IN_POINT_COM_ID,0);
        
    END IF;

    EXCEPTION
    WHEN NO_GET_POINT_EXCEPT THEN
    O_ERRCODE := 'ERR_NO_GET_POINT';
    O_ERRMSG := '포인트적립 불가입니다';
    
    WHEN OTHERS THEN
    O_ERRCODE := SQLCODE;
    O_ERRMSG := SQLERRM;
    
  END PROC_INS_POINT;
  
  --포인트 조회 프로시저
  PROCEDURE PROC_SEL_POINT
  (
    IN_USER_ID      IN VARCHAR2,
    IN_ORDER_ID     IN VARCHAR2,
    O_CUR           OUT SYS_REFCURSOR,
    O_ERRCODE       OUT VARCHAR2,
    O_ERRMSG        OUT VARCHAR2
  ) AS
  
  BEGIN
    
    OPEN O_CUR FOR
    SELECT *
    FROM EARN_POINT_HISTORY_TBL
    WHERE USER_ID LIKE '%' || IN_USER_ID || '%'
    AND ORDER_ID LIKE '%' || IN_ORDER_ID || '%';
    
    EXCEPTION
    WHEN OTHERS THEN
    O_ERRCODE := SQLCODE;
    O_ERRMSG := SQLERRM;
    
  END PROC_SEL_POINT;
  
  --포인트 수정 프로시저
  PROCEDURE PROC_UP_POINT
  (
    INS_IDX IN INTEGER,
    INS_USER_ID IN VARCHAR2,
    INS_ORDER_ID IN VARCHAR2,
    INS_POINT_COMID IN VARCHAR2,
    INS_SAVE_POINT IN VARCHAR2,
    O_ERRCODE OUT VARCHAR2,
    O_ERRMSG OUT VARCHAR2
  ) AS
  
    POINT_GRP_EXCEPTION EXCEPTION;
    
  BEGIN
  
    UPDATE EARN_POINT_HISTORY_TBL
    SET POINT_IDX = INS_IDX, 
        USER_ID = INS_USER_ID, 
        ORDER_ID = INS_ORDER_ID, 
        P_COM_ID = INS_POINT_COMID, 
        EARN_POINT= INS_SAVE_POINT
    WHERE POINT_IDX = INS_IDX;

    EXCEPTION 
    WHEN OTHERS THEN
    O_ERRCODE:=SQLCODE;
    O_ERRMSG:=SQLERRM;
    
  END PROC_UP_POINT;

END PKG_POINT;