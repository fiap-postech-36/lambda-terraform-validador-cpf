def lambda_handler(event, context):
    cpf = event.get('cpf', '')

    def is_valid_cpf(cpf):
        cpf = ''.join(filter(str.isdigit, cpf))  # Remove caracteres não numéricos

        if len(cpf) != 11 or cpf == cpf[0] * 11:
            return False

        def calc_digit(cpf, factor):
            total = sum(int(digit) * (factor - i) for i, digit in enumerate(cpf[:factor-1]))
            remainder = total * 10 % 11
            return 0 if remainder == 10 else remainder

        if calc_digit(cpf, 10) != int(cpf[9]) or calc_digit(cpf, 11) != int(cpf[10]):
            return False

        return True

    valid = is_valid_cpf(cpf)

    return {
        'statusCode': 200,
        'body': {
            'valid': valid,
            'cpf': cpf
        }
    }
