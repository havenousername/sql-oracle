DECLARE
  P_CHAR VARCHAR2(200);
  v_Return NUMBER;
BEGIN
  P_CHAR := NULL;

  v_Return := SUM_OF2(
    P_CHAR => P_CHAR
  );
  /* Legacy output: 
DBMS_OUTPUT.PUT_LINE('v_Return = ' || v_Return);
*/ 
  :v_Return := v_Return;
--rollback; 
END;
