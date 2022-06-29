create or replace NONEDITIONABLE PACKAGE PKG_ORDER AS 

  --주문 등록 프로시저
  PROCEDURE PROC_INS_ORDER
  (
    IN_ORDER_ID        IN VARCHAR2,
    IN_USER_ID         IN VARCHAR2,
    IN_STORE_ID        IN VARCHAR2,
    IN_MENU_ID         IN VARCHAR2,
    IN_QUANTITY       IN VARCHAR2,
    IN_TAKE_OUT        IN VARCHAR2,
    IN_ORDER_DATE      IN VARCHAR2,
    O_ERRCODE          OUT VARCHAR2,
    O_ERRMSG           OUT VARCHAR2
  );
 
  --주문 조회 프로시저 
  PROCEDURE PROC_SEL_ORDER
  (
    IN_ORDER_ID        IN VARCHAR2,
    IN_USER_ID         IN VARCHAR2,
    IN_STORE_ID        IN VARCHAR2,
    IN_MENU_ID         IN VARCHAR2,
    O_CUR              OUT SYS_REFCURSOR,
    O_ERRCODE          OUT VARCHAR2,
    O_ERRMSG           OUT VARCHAR2
  );
  
  --주문 수정 프로시저
  PROCEDURE PROC_UP_ORDER
  (
    IN_ORDER_IDX       IN VARCHAR2,
    IN_ORDER_ID        IN VARCHAR2,
    IN_USER_ID         IN VARCHAR2,
    IN_STORE_ID        IN VARCHAR2,
    IN_MENU_ID         IN VARCHAR2,
    IN_QUANTITY       IN VARCHAR2,
    IN_TAKE_OUT        IN VARCHAR2,
    IN_ORDER_DATE      IN VARCHAR2,
    O_ERRCODE          OUT VARCHAR2,
    O_ERRMSG           OUT VARCHAR2
  );
  
  --주문 삭제 프로시저
    PROCEDURE PROC_DEL_ORDER
    (
        INS_ORDER_ID IN VARCHAR2,
        O_ERRCODE OUT VARCHAR2,
        O_ERRMSG OUT VARCHAR2
    );

END PKG_ORDER;