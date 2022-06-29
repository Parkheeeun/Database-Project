CREATE OR REPLACE PACKAGE BODY PKG_ORDER_ACT AS

  PROCEDURE PROC_INS_ORDER_LIST
    (
        IN_DELIVERY_FEE     IN      NUMBER,
        IN_POINT_USE        IN      VARCHAR2,
        O_ERR_CODE         OUT      VARCHAR2,
        O_ERR_MSG          OUT      VARCHAR2
    ) AS
        V_NEW_ORDER_IDX     NUMBER(10);
        V_NEW_ORDER_ID      CHAR(6);
        V_DELIVERY_CHK      CHAR(1);
        V_TOTAL_PRICE       NUMBER(10);
        V_ORDER_STATUS      VARCHAR2(10);
        INTO_DELIVERY_FEE   NUMBER(5) := 0;
        V_FINISH_ORDER      NUMBER(3);
        V_MIN_PRICE_CHK     NUMBER(10);
        V_TIME_CHK          NUMBER(3);
        
        EXCEPT_NOT_POINT_USE    EXCEPTION;
        EXCEPT_NOT_TAKE_OUT     EXCEPTION;
        EXCEPT_FINISH_ORDER     EXCEPTION;
        
  BEGIN
    
    SELECT MAX(ORDER_IDX) + 1
    INTO V_NEW_ORDER_IDX
    FROM ORDER_LIST_TBL;
    
    --ORDER_TBL에서 가장 최근 ORDER_ID 받기
    SELECT MAX(ORDER_ID)
    INTO V_NEW_ORDER_ID
    FROM ORDER_TBL;
    
    
    --배달 포장 확인 
    SELECT TAKE_OUT 
    INTO V_DELIVERY_CHK
    FROM ORDER_TBL
    WHERE ORDER_ID = V_NEW_ORDER_ID
    GROUP BY ORDER_ID, TAKE_OUT
    ;
    
    --포장 -> D_FEE 0원
    IF V_DELIVERY_CHK = 'X' THEN
        INTO_DELIVERY_FEE := IN_DELIVERY_FEE;
    END IF;
    
    --ORDER_TBL 에서 ORDER_ID 로 GROUP BY 해서 수량 X 가격 계산값
    SELECT SUM( T1.QUANTITY * T2.MENU_PRICE )
    INTO V_TOTAL_PRICE
    FROM ORDER_TBL T1, MENU_TBL T2
    WHERE T1.MENU_ID = T2.MENU_ID
    AND T1.ORDER_ID = V_NEW_ORDER_ID
    GROUP BY T1.ORDER_ID
    ;
    
    --POINT_USE 입력값 O X 제한
    IF IN_POINT_USE != 'O' AND IN_POINT_USE != 'X' THEN
    RAISE EXCEPT_NOT_POINT_USE;
    END IF;
    
    SELECT DECODE(MAX(ORDER_ID),NULL,0,1)
    INTO V_FINISH_ORDER
    FROM ORDER_LIST_TBL
    WHERE ORDER_ID = V_NEW_ORDER_ID
    AND (ORDER_STATUS = 'A' OR ORDER_STATUS = 'C')
    ;
    
    IF V_FINISH_ORDER = 1 THEN
        RAISE EXCEPT_FINISH_ORDER;
    END IF;
    
    INSERT INTO ORDER_LIST_TBL
    (
        ORDER_IDX,
        ORDER_ID,
        DELIVERY_FEE,
        TOTAL_PRICE,
        USE_POINT,
        ORDER_STATUS
    )
    VALUES
    (
        V_NEW_ORDER_IDX,
        V_NEW_ORDER_ID,
        INTO_DELIVERY_FEE,
        V_TOTAL_PRICE,
        IN_POINT_USE,
        'A'
    );
    
    SELECT MIN_PRICE 
    INTO V_MIN_PRICE_CHK
    FROM
    (
    SELECT T1.STORE_ID, T1.MIN_PRICE,T3.ORDER_ID FROM STORE_TBL T1, ORDER_TBL T2, ORDER_LIST_TBL T3
    WHERE T1.STORE_ID = T2.STORE_ID
    AND T2.ORDER_ID = T3.ORDER_ID
    GROUP BY T1.STORE_ID, T1.MIN_PRICE,T3.ORDER_ID
    )
    WHERE ORDER_ID = V_NEW_ORDER_ID
    ;
    
        SELECT DECODE(MAX(ORDER_ID),NULL,1,0) 
        INTO V_TIME_CHK
        FROM
        (
            SELECT ORDER_ID FROM
        (
            SELECT A.ORDER_ID,B.STORE_ID,B.ORDER_TIME FROM ORDER_LIST_TBL A,
        (SELECT ORDER_ID,TO_CHAR(ORDER_DATE,'HH24MI') AS ORDER_TIME,STORE_ID FROM ORDER_TBL
        GROUP BY ORDER_ID,ORDER_DATE,STORE_ID)
        B
            WHERE A.ORDER_ID = B.ORDER_ID AND A.ORDER_STATUS='A'
        ) T1,
        STORE_TBL T2 
        WHERE T1.STORE_ID=T2.STORE_ID
        AND NOT (T2.OPEN_TIME <= T1.ORDER_TIME AND T1.ORDER_TIME <=T2.CLOSE_TIME+2400)
        )
        WHERE ORDER_ID = V_NEW_ORDER_ID
        ;
    
    IF V_MIN_PRICE_CHK > V_TOTAL_PRICE THEN
        INSERT INTO ORDER_LIST_TBL
        (
            ORDER_ID,
            DELIVERY_FEE,
            TOTAL_PRICE,
            USE_POINT,
            ORDER_STATUS
        )
        VALUES
        (
            V_NEW_ORDER_ID,
            INTO_DELIVERY_FEE,
            V_TOTAL_PRICE,
            IN_POINT_USE,
            'C'
        );
    ELSIF V_TIME_CHK = 0 THEN
        INSERT INTO ORDER_LIST_TBL
        (
            ORDER_ID,
            DELIVERY_FEE,
            TOTAL_PRICE,
            USE_POINT,
            ORDER_STATUS
        )
        VALUES
        (
            V_NEW_ORDER_ID,
            INTO_DELIVERY_FEE,
            V_TOTAL_PRICE,
            IN_POINT_USE,
            'C'
        );         
    END IF;
   
    EXCEPTION
    
    WHEN EXCEPT_NOT_POINT_USE THEN
    O_ERR_CODE := 'ERR202';
    O_ERR_MSG := 'POINT_USE에 올바른 표기법으로 입력해 주세요';
    
    WHEN EXCEPT_FINISH_ORDER THEN
    O_ERR_CODE := 'ERR203';
    O_ERR_MSG := '완료된 주문입니다';
    
    WHEN OTHERS THEN
    O_ERR_CODE := SQLCODE;
    O_ERR_MSG := SQLERRM;
  
  END PROC_INS_ORDER_LIST;

  PROCEDURE PROC_INS_PAYMENT_LIST
    (
        IN_ORDER_ID         IN             VARCHAR2,
        IN_PRICE            IN             NUMBER,
        IN_PRICE_POINT      IN             NUMBER,
        IN_PAYMENT_METHOD   IN             VARCHAR2,
        O_ERR_CODE          OUT            VARCHAR2,
        O_ERR_MSG           OUT            VARCHAR2
    ) AS
    V_PAYMENT_IDX           NUMBER(10);
    V_ORDER_ID_CNT          NUMBER(3);
    V_TOTAL_PRICE_CHK       NUMBER(10);
    V_TOTAL_PRICE           NUMBER(10);
    INTO_DELIVERY_FEE       NUMBER(5);
    INTO_COM_ID             CHAR(6);
    V_POINT_USE_CHK         CHAR(1);
    V_USER_CHK              NUMBER(3);
    V_POINT_CHK             NUMBER(3);
    V_POINT_PRICE           NUMBER(10);
    V_CANCEL_CHK            NUMBER(3);
    
    EXCEPT_NOT_USER               EXCEPTION;
    EXCEPT_NOT_ENOUGH_PRICE       EXCEPTION;
    EXCEPT_NOT_ENOUGH_POINT       EXCEPTION;
    DONT_SEL_POINT                EXCEPTION;
    IS_NOT_ORDER                  EXCEPTION;
    EXCEPT_NOT_ORDER              EXCEPTION;
    POINT_NOT_USE                 EXCEPTION;
  BEGIN    
  
    SELECT MAX(PAYMENT_IDX) + 1 
    INTO V_PAYMENT_IDX
    FROM PAYMENT_HISTORY_TBL;
    
    -- ORDER_LIST_TBL의 접수된 ORDER_ID 확인
    SELECT DECODE(MAX(ORDER_ID),NULL,0,1)
    INTO V_ORDER_ID_CNT
    FROM ORDER_LIST_TBL
    WHERE ORDER_ID = IN_ORDER_ID
    AND ORDER_STATUS = 'A'
    ;
    
    IF V_ORDER_ID_CNT = 0 THEN
        RAISE EXCEPT_NOT_ORDER;
    END IF;
    
    SELECT DECODE(MAX(ORDER_ID),NULL,1,0)
    INTO V_CANCEL_CHK
    FROM ORDER_LIST_TBL
    WHERE ORDER_STATUS = 'C'
    AND ORDER_ID = IN_ORDER_ID
    ;
    
    IF V_CANCEL_CHK = 0 THEN
        RAISE IS_NOT_ORDER;
    END IF;
    
    SELECT COM_ID 
    INTO INTO_COM_ID
    FROM COMMON_TBL
    WHERE GRP_ID = 'GRP003'
    AND COM_VAL LIKE '%' || TRIM(IN_PAYMENT_METHOD) || '%'
    ;
    
    IF INTO_COM_ID = 'COM003' THEN
    RAISE DONT_SEL_POINT;
    END IF;
  
  /*  배달비, 총금액 각각 변수로 받음으로 지움
    -- 배달비, 총금액 합산 
    SELECT DELIVERY_FEE + TOTAL_PRICE
    INTO V_TOTAL_PRICE_CHK
    FROM ORDER_LIST_TBL
    WHERE ORDER_STATUS = '접수'
    AND ORDER_ID = IN_ORDER_ID
    GROUP BY ORDER_ID, DELIVERY_FEE + TOTAL_PRICE
    ;
*/
    
    -- 총금액
    SELECT TOTAL_PRICE
    INTO V_TOTAL_PRICE
    FROM ORDER_LIST_TBL
    WHERE ORDER_STATUS = 'A'
    AND ORDER_ID = IN_ORDER_ID
    GROUP BY ORDER_ID,TOTAL_PRICE
    ;

    --배달비
    SELECT DELIVERY_FEE
    INTO INTO_DELIVERY_FEE
    FROM ORDER_LIST_TBL
    WHERE ORDER_STATUS = 'A'
    AND ORDER_ID = IN_ORDER_ID
    GROUP BY ORDER_ID, DELIVERY_FEE
    ;
    
    SELECT USE_POINT 
    INTO V_POINT_USE_CHK
    FROM ORDER_LIST_TBL
    WHERE ORDER_STATUS = 'A'
    AND ORDER_ID = IN_ORDER_ID
    ;
    
    IF V_POINT_USE_CHK = 'X' THEN
        IF IN_PRICE_POINT != 0 THEN
            RAISE POINT_NOT_USE;
        END IF;
    END IF;
    
    
    IF V_POINT_USE_CHK = 'O' THEN
        -- 주문에 해당하는 USER_ID가 POINT_TBL에 있는지 확인
        
        SELECT DECODE(MAX(USER_ID), NULL, 0, 1)
        INTO V_USER_CHK
        FROM 
        (
            SELECT T1.USER_ID, T2.ORDER_ID, T1.EARN_POINT
            FROM EARN_POINT_HISTORY_TBL T1, ORDER_TBL T2
            WHERE T1.USER_ID = T2.USER_ID
            GROUP BY T1.USER_ID, T2.ORDER_ID, T1.EARN_POINT
        )
        WHERE ORDER_ID = IN_ORDER_ID
        ;
        
        IF V_USER_CHK = 0 THEN
         RAISE EXCEPT_NOT_USER;
        END IF;
        
        SELECT EARN_POINT
        INTO V_POINT_CHK
        FROM 
        (
            SELECT T1.USER_ID, T2.ORDER_ID, T1.EARN_POINT
            FROM EARN_POINT_HISTORY_TBL T1, ORDER_TBL T2
            WHERE T1.USER_ID = T2.USER_ID
            GROUP BY T1.USER_ID, T2.ORDER_ID, T1.EARN_POINT
        )
        WHERE ORDER_ID = IN_ORDER_ID
        ;
        
        --포인트 부족하면 오류
        IF IN_PRICE_POINT > V_POINT_CHK THEN
            RAISE EXCEPT_NOT_ENOUGH_POINT;
        END IF;
    END IF;
    
    IF (V_TOTAL_PRICE + INTO_DELIVERY_FEE)  > (IN_PRICE + IN_PRICE_POINT) THEN
        RAISE EXCEPT_NOT_ENOUGH_PRICE;
    END IF;
    
    -- 금액 입력받고 나머지 TOTAL-PRICE 는 포인트로 계산한다 가정, 포인트가 충분하지 않을시 예외처리 해주기

    INSERT INTO PAYMENT_HISTORY_TBL
    (
        PAYMENT_IDX,
        ORDER_ID,
        FINAL_PRICE,
        PAY_GRP_ID,
        PAY_COM_ID
    )
    VALUES
    (
        V_PAYMENT_IDX,
        IN_ORDER_ID,
        IN_PRICE,
        'GRP003',
        INTO_COM_ID
    );
    
    INSERT INTO PAYMENT_HISTORY_TBL
    (
        PAYMENT_IDX,
        ORDER_ID,
        FINAL_PRICE,
        PAY_GRP_ID,
        PAY_COM_ID
    )
    VALUES
    (
        V_PAYMENT_IDX,
        IN_ORDER_ID,
        IN_PRICE_POINT,
        'GRP003',
        'COM003'
    );
    
    INSERT INTO ORDER_LIST_TBL
        (
            ORDER_ID,
            DELIVERY_FEE,
            TOTAL_PRICE,
            USE_POINT,
            ORDER_STATUS
        )
        VALUES
        (
            IN_ORDER_ID,
            INTO_DELIVERY_FEE,
            V_TOTAL_PRICE,
            V_POINT_USE_CHK,
            'B'
        );         
    
    EXCEPTION
    
    WHEN EXCEPT_NOT_USER THEN
    O_ERR_CODE := 'ERR101';
    O_ERR_MSG := 'POINT_TBL에 없는 USER_ID 이므로 POINT를 쓸 수 없습니다';
    
    WHEN EXCEPT_NOT_ENOUGH_PRICE THEN
    O_ERR_CODE := 'ERR102';
    O_ERR_MSG := '입력하신 금액이 충분하지 않습니다';
    
    WHEN EXCEPT_NOT_ENOUGH_POINT THEN
    O_ERR_CODE := 'ERR103';
    O_ERR_MSG := '적립된 포인트가 충분하지 않습니다';
    
    WHEN DONT_SEL_POINT THEN
    O_ERR_CODE := 'ERR104';
    O_ERR_MSG := '현금과 카드중에서 골라주세요';
    
    WHEN EXCEPT_NOT_ORDER THEN
    O_ERR_CODE := 'ERR105';
    O_ERR_MSG := '주문목록에 없는 주문ID 입니다';
    
    WHEN IS_NOT_ORDER THEN
    O_ERR_CODE := 'ERR106';
    O_ERR_MSG := '취소된 주문ID 입니다';
    
    WHEN POINT_NOT_USE THEN
    O_ERR_CODE := 'ERR107';
    O_ERR_MSG := '포인트 사용 여부를 확인해 주세요';
    
    WHEN OTHERS THEN
    O_ERR_CODE := SQLCODE;
    O_ERR_MSG := SQLERRM; 
  
  END PROC_INS_PAYMENT_LIST;

  PROCEDURE PROC_INS_POINT
    (
        IN_ORDER_ID           IN          VARCHAR2,
        O_ERR_CODE         OUT         VARCHAR2,
        O_ERR_MSG          OUT         VARCHAR2
    ) AS
        V_USE_POINT     VARCHAR2(10);
        V_USER_ID       VARCHAR2(10);
        V_TOTAL_PRICE   NUMBER;
        V_POINT_PER     VARCHAR2(10);
        V_FINAL_PRICE   NUMBER;
        V_NEW_POINT_IDX NUMBER;
        V_USER_POINT    NUMBER;
        V_NEW_EARN_POINT    NUMBER;
  BEGIN
  
        --포인트 사용여부 불러오기
        SELECT USE_POINT 
        INTO V_USE_POINT
        FROM ORDER_LIST_TBL
        WHERE ORDER_ID=IN_ORDER_ID AND ORDER_STATUS='B';
        
        -- ORDER_ID로 USER_ID 불러오기
        SELECT USER_ID 
        INTO V_USER_ID
        FROM ORDER_TBL
        WHERE ORDER_ID=IN_ORDER_ID
        GROUP BY ORDER_ID,USER_ID;
    
        -- 적립할 금액 불러오기
        SELECT TOTAL_PRICE 
        INTO V_TOTAL_PRICE
        FROM ORDER_LIST_TBL
        WHERE ORDER_ID=IN_ORDER_ID AND ORDER_STATUS='B' AND USE_POINT=V_USE_POINT;
    
        -- 적립율 불러오기
        
        SELECT TO_NUMBER(COM_VAL) 
        INTO V_POINT_PER
        FROM COMMON_TBL
        WHERE GRP_ID='GRP005' AND COM_ID='COM001';
        
        --포인트 결제 금액 찾기
        IF V_USE_POINT = 'O' THEN
            SELECT FINAL_PRICE 
            INTO V_FINAL_PRICE
            FROM PAYMENT_HISTORY_TBL
            WHERE ORDER_ID=IN_ORDER_ID AND PAY_COM_ID='COM003';
        END IF;
        
        --USER 포인트 찾기
        SELECT USER_POINT 
        INTO V_USER_POINT
        FROM USER_TBL
        WHERE USER_ID=V_USER_ID;
        
        SELECT NVL(MAX(POINT_IDX),0) + 1 
        INTO V_NEW_POINT_IDX
        FROM EARN_POINT_HISTORY_TBL;
        

        IF V_USE_POINT ='X' THEN
            INSERT INTO EARN_POINT_HISTORY_TBL VALUES(V_NEW_POINT_IDX,V_USER_ID,IN_ORDER_ID,'GRP005','COM001',V_TOTAL_PRICE * V_POINT_PER);
        END IF;
        
        IF V_USE_POINT='O' THEN
            UPDATE USER_TBL SET USER_POINT=V_USER_POINT - V_FINAL_PRICE WHERE USER_ID=V_USER_ID;
        END IF;
        
        SELECT EARN_POINT 
        INTO V_NEW_EARN_POINT
        FROM EARN_POINT_HISTORY_TBL
        WHERE POINT_IDX=V_NEW_POINT_IDX;
        
        UPDATE USER_TBL SET USER_POINT=V_USER_POINT + V_NEW_EARN_POINT WHERE USER_ID=V_USER_ID; 
        
        
        
        
  END PROC_INS_POINT;

  PROCEDURE PROC_INS_DELIVERY_ORDER
    (
        IN_ORDER_ID         IN             VARCHAR2,
        IN_DRIVER_ID        IN             VARCHAR2,
        IN_ORDER_TIME       IN             VARCHAR2,
        IN_EXPICKUP_TIME    IN             VARCHAR2,
        O_ERR_CODE         OUT             VARCHAR2,
        O_ERR_MSG          OUT             VARCHAR2
    ) AS
  BEGIN
    -- TODO: PROCEDURE PKG_ORDER_ACT.PROC_INS_DELIVERY_ORDER에 대해 구현이 필요합니다.
    NULL;
  END PROC_INS_DELIVERY_ORDER;

   PROCEDURE PROC_SEL_ORDER_LIST
    (
        IN_ORDER_ID         IN      VARCHAR2,
        IN_DELIVERY_FEE     IN      NUMBER,
        IN_POINT_USE        IN      VARCHAR2,
        IN_ORDER_STATUS     IN      VARCHAR2,
        O_CURSOR           OUT      SYS_REFCURSOR,
        O_ERR_CODE         OUT      VARCHAR2,
        O_ERR_MSG          OUT      VARCHAR2
    ) AS
  BEGIN
    OPEN O_CURSOR FOR
        SELECT * FROM ORDER_LIST_TBL
        WHERE
            ORDER_ID      LIKE '%' || IN_ORDER_ID     || '%'
        AND DELIVERY_FEE  LIKE '%' || IN_DELIVERY_FEE || '%'
        AND USE_POINT     LIKE '%' || IN_POINT_USE    || '%'
        AND ORDER_STATUS  LIKE '%' || IN_ORDER_STATUS || '%'
      ;
      
      EXCEPTION
      WHEN OTHERS THEN
      O_ERR_CODE := SQLCODE;
      O_ERR_MSG  := SQLERRM;
        
    

  END PROC_SEL_ORDER_LIST;


--결재내역 테이블 SELECT
  PROCEDURE PROC_SEL_PAYMENT_LIST
    (
        IN_ORDER_ID            IN             VARCHAR2,
        IN_GRP_ID              IN             VARCHAR2,
        IN_COM_ID              IN             VARCHAR2,
        O_CURSOR           OUT             SYS_REFCURSOR,
        O_ERR_CODE         OUT             VARCHAR2,
        O_ERR_MSG          OUT             VARCHAR2
    ) AS
  BEGIN
    OPEN O_CURSOR FOR
        SELECT *FROM PAYMENT_HISTORY_TBL
        WHERE
            ORDER_ID      LIKE '%' || IN_ORDER_ID     || '%'
        AND PAY_GRP_ID  LIKE '%' || IN_GRP_ID || '%'
        AND PAY_COM_ID  LIKE '%' || IN_COM_ID || '%'
      ;
      
      EXCEPTION
      WHEN OTHERS THEN
      O_ERR_CODE := SQLCODE;
      O_ERR_MSG  := SQLERRM;
      
  END PROC_SEL_PAYMENT_LIST;
  
  --포인트 테이블 SELECT 
  PROCEDURE PROC_SEL_POINT
    (
        IN_USER_ID            IN          VARCHAR2,
        IN_ORDER_ID           IN          VARCHAR2,
        O_CURSOR           OUT         SYS_REFCURSOR,
        O_ERR_CODE         OUT         VARCHAR2,
        O_ERR_MSG          OUT         VARCHAR2
    ) AS
  BEGIN
    OPEN O_CURSOR FOR
        SELECT *FROM EARN_POINT_HISTORY_TBL
        WHERE
            USER_ID      LIKE '%' || IN_USER_ID   || '%'
        AND ORDER_ID  LIKE '%' || IN_ORDER_ID || '%'
      ;
      
      EXCEPTION
      WHEN OTHERS THEN
      O_ERR_CODE := SQLCODE;
      O_ERR_MSG  := SQLERRM;
  END PROC_SEL_POINT;

 --배달오더 테이블 SELECT
  PROCEDURE PROC_SEL_DELIVERY_ORDER
    (
        IN_ORDER_ID         IN             VARCHAR2,
        IN_DRIVER_ID        IN             VARCHAR2,
        O_CURSOR           OUT             SYS_REFCURSOR,
        O_ERR_CODE         OUT             VARCHAR2,
        O_ERR_MSG          OUT             VARCHAR2
    ) AS
  BEGIN
    OPEN O_CURSOR FOR
        SELECT *FROM DELIVERY_ORDER_TBL
        WHERE
            ORDER_ID      LIKE '%' || IN_ORDER_ID     || '%'
        AND DRIVER_ID  LIKE '%' || IN_DRIVER_ID || '%'
      ;
      
      EXCEPTION
      WHEN OTHERS THEN
      O_ERR_CODE := SQLCODE;
      O_ERR_MSG  := SQLERRM;
  END PROC_SEL_DELIVERY_ORDER;
  
    PROCEDURE PROC_UP_ORDER_LIST
    (
        IN_ORDER_ID         IN      VARCHAR2,
        IN_DELIVERY_FEE     IN      NUMBER,
        IN_PRICE            IN      NUMBER,
        IN_PRICE_POINT      IN      NUMBER,
        O_ERR_CODE         OUT      VARCHAR2,
        O_ERR_MSG          OUT      VARCHAR2
    ) AS
        V_TOTAL_PRICE       NUMBER(10);
        
        NOT_ENOUGH_PRICE    EXCEPTION;
    BEGIN    
        
        --취소 아닌 ORDER_ID에 배달료 업데이트
        UPDATE ORDER_LIST_TBL
        SET DELIVERY_FEE = IN_DELIVERY_FEE
        WHERE ORDER_ID = IN_ORDER_ID
        AND ORDER_STATUS != '취소'
        ;
        
        -- 총 금액 값 저장
        SELECT TOTAL_PRICE
        INTO V_TOTAL_PRICE
        FROM ORDER_LIST_TBL
        WHERE ORDER_ID = IN_ORDER_ID
        GROUP BY ORDER_ID, TOTAL_PRICE
        ;
        
        -- 배달료, 물건 총 금액 합계 맞는지 확인       
        IF V_TOTAL_PRICE != (IN_PRICE + IN_PRICE_POINT) THEN
            RAISE NOT_ENOUGH_PRICE;
        END IF;
        
        -- PAYMENT PRLICE 금액 업데이트
        UPDATE PAYMENT_HISTORY_TBL
        SET FINAL_PRICE = IN_PRICE
        WHERE ORDER_ID = IN_ORDER_ID
        AND (PAY_COM_ID = 'COM001' OR PAY_COM_ID = 'COM002')
        ;
        -- PAYMENT POINT 금액 업데이트
        UPDATE PAYMENT_HISTORY_TBL
        SET FINAL_PRICE = IN_PRICE_POINT
        WHERE ORDER_ID = IN_ORDER_ID
        AND PAY_COM_ID = 'COM003'
        ;
        
        
        EXCEPTION
        WHEN NOT_ENOUGH_PRICE THEN
        O_ERR_CODE := 'ERR107';
        O_ERR_MSG := '결제하시려는 금액이 총 금액과 맞지 않습니다';
    
        WHEN OTHERS THEN
        O_ERR_CODE := SQLCODE;
        O_ERR_MSG := SQLERRM; 
        
    
    END PROC_UP_ORDER_LIST;

  PROCEDURE PROC_DEL_ORDER_LIST
    (
        IN_ORDER_ID         IN      VARCHAR2,
        O_ERR_CODE         OUT      VARCHAR2,
        O_ERR_MSG          OUT      VARCHAR2
    ) AS
    V_NEW_ORDER_IDX         NUMBER;
    V_CNT_ORDER_ID          NUMBER;
    V_DELIVERY_FEE          NUMBER;
    V_TOTAL_PRICE           NUMBER;
    V_USE_POINT            VARCHAR2(50);
    V_PAYMENT_IDX           NUMBER;
    V_PAY_GRP_ID            VARCHAR2(50);
    V_PAY_COM_ID            VARCHAR2(50);
    V_FINAL_PRICE_POINT     NUMBER;
    V_FINAL_PRICE_MONEY     NUMBER;
  BEGIN


    -- DELETE 변수 불러오기    
    SELECT MAX(ORDER_IDX) + 1 
    INTO V_NEW_ORDER_IDX
    FROM ORDER_LIST_TBL;
    
    SELECT COUNT(*) 
    INTO V_CNT_ORDER_ID
    FROM
    (
        SELECT ORDER_ID 
        FROM ORDER_LIST_TBL
        WHERE ORDER_STATUS='A' AND ORDER_ID=IN_ORDER_ID
    ) A, PAYMENT_HISTORY_TBL B
    WHERE A.ORDER_ID = B.ORDER_ID;
    
    SELECT DELIVERY_FEE 
    INTO V_DELIVERY_FEE
    FROM ORDER_LIST_TBL
    WHERE ORDER_ID=IN_ORDER_ID AND ORDER_STATUS='A';
    
    SELECT TOTAL_PRICE 
    INTO V_TOTAL_PRICE
    FROM ORDER_LIST_TBL
    WHERE ORDER_ID=IN_ORDER_ID AND ORDER_STATUS='A';
    
    SELECT USE_POINT 
    INTO V_USE_POINT
    FROM ORDER_LIST_TBL
    WHERE ORDER_ID=IN_ORDER_ID AND ORDER_STATUS='A';
    
    SELECT MAX(PAY_GRP_ID) 
    INTO V_PAY_GRP_ID
    FROM PAYMENT_HISTORY_TBL
    WHERE ORDER_ID=IN_ORDER_ID;
    
    SELECT PAY_COM_ID
    INTO  V_PAY_COM_ID
    FROM PAYMENT_HISTORY_TBL
    WHERE ORDER_ID=IN_ORDER_ID
    AND PAY_COM_ID != 'COM003';
    
    SELECT FINAL_PRICE 
    INTO V_FINAL_PRICE_POINT
    FROM PAYMENT_HISTORY_TBL
    WHERE ORDER_ID=IN_ORDER_ID AND PAY_COM_ID='COM003';
    
    SELECT FINAL_PRICE
    INTO V_FINAL_PRICE_MONEY
    FROM PAYMENT_HISTORY_TBL
    WHERE ORDER_ID=IN_ORDER_ID AND (PAY_COM_ID='COM001' OR PAY_COM_ID='COM002');
    
    SELECT MAX(PAYMENT_IDX) + 1 
    INTO V_PAYMENT_IDX
    FROM PAYMENT_HISTORY_TBL;
    
    -- 변수 불러오기 끝
    
    -- V_CNT_ORDER_ID = 0 이면 주문목록 테이블에서 취소 해버리면 됨...
    -- V_CNT_ORDER_ID = 1 이면 주문목록 테이블에서 취소, 결제목록에서 FINAL_PRICE에 - 붙혀서 INSERT
    -- V_CNT_ORDER_ID = 2 이면 주문목록 테이블에서 취소, 결제목록에서 FINAL_PRICE_MONEY, FINAL_PRICE_POINT에 - 붙혀서 INSERT..
    
    IF V_CNT_ORDER_ID=0 THEN
       INSERT INTO ORDER_LIST_TBL VALUES(V_NEW_ORDER_IDX,IN_ORDER_ID,V_DELIVERY_FEE,V_TOTAL_PRICE,V_USE_POINT,'C');
    ELSIF V_CNT_ORDER_ID=1 THEN
        INSERT INTO ORDER_LIST_TBL VALUES(V_NEW_ORDER_IDX,IN_ORDER_ID,V_DELIVERY_FEE,V_TOTAL_PRICE,V_USE_POINT,'C');
        INSERT INTO PAYMENT_HISTORY_TBL VALUES(V_PAYMENT_IDX,IN_ORDER_ID,-V_FINAL_PRICE_MONEY,'GRP003',V_PAY_COM_ID);
    ELSIF   V_CNT_ORDER_ID=2 THEN
        INSERT INTO ORDER_LIST_TBL VALUES(V_NEW_ORDER_IDX,IN_ORDER_ID,V_DELIVERY_FEE,V_TOTAL_PRICE,V_USE_POINT,'C');
        INSERT INTO PAYMENT_HISTORY_TBL VALUES(V_PAYMENT_IDX,IN_ORDER_ID,-V_FINAL_PRICE_MONEY,'GRP003',V_PAY_COM_ID);
        INSERT INTO PAYMENT_HISTORY_TBL VALUES(V_PAYMENT_IDX + 1,IN_ORDER_ID,-V_FINAL_PRICE_POINT,'GRP003','COM003');
    ELSE
        NULL;
    END IF;
    
    
    EXCEPTION
      WHEN OTHERS THEN
      O_ERR_CODE := SQLCODE;
      O_ERR_MSG  := SQLERRM;
    
  END PROC_DEL_ORDER_LIST;

END PKG_ORDER_ACT;