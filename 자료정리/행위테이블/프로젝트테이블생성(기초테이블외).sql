--주문 테이블
CREATE TABLE ORDER_TBL
(
    ORDER_IDX           NUMBER(10)          PRIMARY KEY,
    ORDER_ID            CHAR(6)             NOT NULL,
    USER_ID             CHAR(6)             NOT NULL,
    STORE_ID            CHAR(6)             NOT NULL,
    MENU_ID             CHAR(6)             NOT NULL,
    QUANTITY            NUMBER(6)           NOT NULL,
    TAKE_OUT            CHAR(1)             NOT NULL,  -- O: 포장 , X : 배달
    ORDER_DATE          DATE                NOT NULL
)
;
--주문 목록테이블
CREATE TABLE ORDER_LIST_TBL
(
    ORDER_IDX           NUMBER(10)     PRIMARY KEY,
    ORDER_ID            CHAR(6)        NOT NULL,
    DELIVERY_FEE        NUMBER(6)       NOT NULL,
    TOTAL_PRICE         NUMBER(10)      NOT NULL,
    USE_POINT           CHAR(1)         NOT NULL,  -- O : 사용 , X : 미사용
    ORDER_STATUS        CHAR(3)         NOT NULL  --- A: 접수 , B : 완료 , C : 취소
)
;
--리뷰 테이블
CREATE TABLE REVIEW_TBL
(
    REVIEW_ID       CHAR(6)         PRIMARY KEY,
    ORDER_ID        CHAR(6)         NOT NULL,
    USER_ID         CHAR(6)         NOT NULL,
    STORE_SCORE     NUMBER(3)       NOT NULL,
    WRITE_DATE      DATE            NOT NULL,
    EX_COMMENT      VARCHAR2(200)  NULL
)
;
--리뷰 사진 테이블
CREATE TABLE REVIEW_PHOTO_TBL
(
    PHOTO_ID    CHAR(6)         PRIMARY KEY,
    REVIW_ID    CHAR(6)         NOT NULL,
    FILE_NAME   VARCHAR2(100)   NOT NULL
)
;
--결재내역 테이블
CREATE TABLE PAYMENT_HISTORY_TBL
(
    PAYMENT_IDX     NUMBER(10)      PRIMARY KEY,
    ORDER_ID        CHAR(6)         NOT NULL,
    FINAL_PRICE     NUMBER(10)      NOT NULL,
    PAY_GRP_ID      CHAR(6)         NOT NULL,
    PAY_COM_ID      CHAR(6)         NOT NULL
)
;
배달 목록테이블
CREATE TABLE DELIVERY_ORDER_TBL
(
    DELIVERY_IDX        NUMBER(10)      PRIMARY KEY,
    ORDER_ID            CHAR(6)         NOT NULL,
    DRIVER_ID           CHAR(6)         NOT NULL,
    ORDER_DATE          DATE            NOT NULL,
    EXPECT_PICK_UP      DATE            NOT NULL
)
;
--포인트 테이블
CREATE TABLE EARN_POINT_HISTORY_TBL
(
    POINT_IDX   NUMBER(10)      PRIMARY KEY,
    USER_ID     CHAR(6)         NOT NULL,
    ORDER_ID    CHAR(6)         NOT NULL,
    P_GRP_ID    CHAR(6)         NOT NULL,
    P_COM_ID    CHAR(6)         NOT NULL,
    EARN_POINT  NUMBER(5)       NOT NULL
)
;


