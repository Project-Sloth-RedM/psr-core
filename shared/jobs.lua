PSRShared = PSRShared or {}
PSRShared.ForceJobDefaultDutyAtLogin = true -- true: Force duty state to jobdefaultDuty | false: set duty state from database last saved

PSRShared.Jobs = {
	['unemployed'] = {
		label = 'Civilian',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
            ['0'] = {
                name = 'Freelancer',
                payment = 10
            },
        },
	},
	['lawmen'] = {
		label = 'Lawmen',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = {
                name = 'Deputy',
                payment = 100
            },
			['1'] = {
                name = 'County Sheriff',
				isboss = true,
                payment = 150
            },
        },
	},
	['doctor'] = {
		label = 'Doctor',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
            ['0'] = {
                name = 'Physician',
                payment = 50
            },
			['1'] = {
                name = 'Surgeon',
                payment = 75
            },
			['2'] = {
                name = 'Doctor',
                isboss = true,
                payment = 100
            },
        },
	},
	['judge'] = {
		label = 'Honorary',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
            ['0'] = {
                name = 'Judge',
                payment = 100
            },
        },
	},
	['lawyer'] = {
		label = 'Law Firm',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
            ['0'] = {
                name = 'Associate',
                payment = 50
            },
        },
	}
}
