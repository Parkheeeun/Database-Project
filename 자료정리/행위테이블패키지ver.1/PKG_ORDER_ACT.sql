CREATE OR REPLACE PACKAGE PKG_ORDER_ACT AS 

     --1. 입력 INSERT
     
     --ORDER_LIST
    PROCEDURE PROC_INS_ORDER_LIST
    (
        IN_DELIVERY_FEE     IN      NUMBER,
        IN_POINT_USE        IN      VARCHAR2,
        O_ERR_CODE         OUT      VARCHAR2,
        O_ERR_MSG          OUT      VARCHAR2
    );
    
    --PAYMENT_LIST
    PROCEDURE PROC_INS_PAYMENT_LIST
    (
        IN_ORDER_ID         IN             VARCHAR2,
        IN_PRICE            IN             NUMBER,
        IN_PRICE_POINT      IN             NUMBER,
        IN_PAYMENT_METHOD   IN             VARCHAR2,
        O_ERR_CODE          OUT            VARCHAR2,
        O_ERR_MSG           OUT            VARCHAR2
    );
    
    --POINT
    PROCEDURE PROC_INS_POINT
    (
        IN_ORDER_ID           IN          VARCHAR2,
        O_ERR_CODE         OUT         VARCHAR2,
        O_ERR_MSG          OUT         VARCHAR2
    );
    
    --DELIVERY_ORDER
    PROCEDURE PROC_INS_DELIVERY_ORDER
    (
        IN_ORDER_ID         IN             VARCHAR2,
        IN_DRIVER_ID        IN             VARCHAR2,
        IN_ORDER_TIME       IN             VARCHAR2,
        IN_EXPICKUP_TIME    IN             VARCHAR2,
        O_ERR_CODE         OUT             VARCHAR2,
        O_ERR_MSG          OUT             VARCHAR2
    );
    
    --2. SELECT
    
    --ORDER_LIST
    PROCEDURE PROC_SEL_ORDER_LIST
    (
        IN_ORDER_ID         IN      VARCHAR2,
        IN_DELIVERY_FEE     IN      NUMBER,
        IN_POINT_USE        IN      VARCHAR2,
        IN_ORDER_STATUS     IN      VARCHAR2,
        O_CURSOR           OUT      SYS_REFCURSOR,
        O_ERR_CODE         OUT      VARCHAR2,
        O_ERR_MSG          OUT      VARCHAR2
    );
    
    --PAYMENT_LIST
    PROCEDURE PROC_SEL_PAYMENT_LIST
    (
        IN_ORDER_ID            IN             VARCHAR2,
        IN_GRP_ID              IN             VARCHAR2,
        IN_COM_ID              IN             VARCHAR2,
        O_CURSOR               OUT            SYS_REFCURSOR,
        O_ERR_CODE             OUT            VARCHAR2,
        O_ERR_MSG              OUT            VARCHAR2
    );
    
    --POINT
    PROCEDURE PROC_SEL_POINT
    (
        IN_USER_ID            IN          VARCHAR2,
        IN_ORDER_ID           IN          VARCHAR2,
        O_CURSOR           OUT         SYS_REFCURSOR,
        O_ERR_CODE         OUT         VARCHAR2,
        O_ERR_MSG          OUT         VARCHAR2
    );
    
    --DELIVERY
    PROCEDURE PROC_SEL_DELIVERY_ORDER
    (
        IN_ORDER_ID         IN             VARCHAR2,
        IN_DRIVER_ID        IN             VARCHAR2,
        O_CURSOR           OUT             SYS_REFCURSOR,
        O_ERR_CODE         OUT             VARCHAR2,
        O_ERR_MSG          OUT             VARCHAR2
    );
    
    --3. UPDATE
    PROCEDURE PROC_UP_ORDER_LIST
    (
        IN_ORDER_ID         IN      VARCHAR2,
        IN_DELIVERY_FEE     IN      NUMBER,
        IN_PRICE            IN      NUMBER,
        IN_PRICE_POINT      IN      NUMBER,
        O_ERR_CODE         OUT      VARCHAR2,
        O_ERR_MSG          OUT      VARCHAR2
    );
    
    --4. DELETE
    PROCEDURE PROC_DEL_ORDER_LIST
    (
        IN_ORDER_ID         IN      VARCHAR2,
        O_ERR_CODE         OUT      VARCHAR2,
        O_ERR_MSG          OUT      VARCHAR2
    );
    -- DELETE FROM ORDER_TBL WHERE ORDER_ID = IN_ORDER_ID;
    
END PKG_ORDER_ACT;
