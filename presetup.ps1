#require Module Plaster





$PlasterParams = @{
    TemplatePath = ".\PSHitchhiker\Module.T\parametersets\"
    Destination = "C:\Users\Operator\Documents\GitHub\PSHitcHiker"
    ModuleName = 'FooUtil'

    PSET1 = 'Ask'

    PSET1_CONTEXT1 = 'Known Answers'
    PSET1_CONTEXT1_IT1 = 'doesnt like questionless questions'
    PSET1_CONTEXT1_IT2 = 'knows the answer to the ultimate question'

    PSET1_CONTEXT2 = 'Random Answers'
    PSET1_CONTEXT2_IT1 = 'returns a random answer for unknown questions'
}



Invoke-Plaster @PlasterParams -Force -Verbose

