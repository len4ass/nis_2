local Visual = function()
	OutLine(GetOpsMoves() .. "\t\t" .. CalcParamsTiers(2) .. "\t\t" ..  CalcParamsTiers(6) .. "\t\t" .. CalcParamsTiers(8))
end

local GetAverageOperatorCount = function()
	local operator_count = 0
	local tier_count = GetCountTiers()
	for tier = 1, tier_count do
		operator_count = operator_count + GetCountOpsOnTier(tier)
	end
	
	return math.ceil(operator_count / tier_count)
end

local Bulldoze = function(average) 
	for tier = 1, GetCountTiers() do
		-- Если операторов больше среднего, то пропускаем ярус
		local operator_count = GetCountOpsOnTier(tier)
		if operator_count <= average then
			goto skip_tier
		end
		
		-- Цикл по операторам на ярусе 
		local moving_tier = 0
		for operator_index = 1, operator_count do
			operator_index = operator_index - moving_tier

			local operator = GetOpByNumbOnTier(operator_index, tier)
			local min_tier = GetMinTierMaybeOp(operator)
			local max_tier = GetMaxTierMaybeOp(operator)

			-- Поиск яруса с минимальным количеством операторов
			local best_tier = tier
			for i = min_tier, max_tier do
				local width = GetCountOpsOnTier(i)
				local min_width = GetCountOpsOnTier(best_tier)
				if i ~= tier and width < average and width <= min_width then
					best_tier = i
				end
			end

			-- Перемещаем оператор на подходящий ярус (если таковой нашелся) и выводим информацию о текущем перемещении
			if best_tier ~= tier then
				MoveOpTierToTier(operator, best_tier)
				Visual()
				moving_tier = moving_tier + 1
			end
		end
		
		::skip_tier::
	end
end

local MainFunction = function()
	CountMovesZeroing()
	ClearTextFrame()
	ClearDiagrArea()
	
	CreateTiersByEdges("korr_20.gv")
	DrawDiagrTiers()
	
	OutLine("=====")
	OutLine("До: ")
	PutTiersToTextFrame()
	PutParamsTiers()

	average_operator_count = GetAverageOperatorCount()
	OutLine("Среднее арифметическое ширин ярусов: " .. average_operator_count)
	
	OutLine("# Перемещения\tШирина\t\tCV\t\tICL")
    Visual()
	Bulldoze(average_operator_count)
	
	OutLine("Всего перемещений: " .. GetOpsMoves())

	OutLine("=====")
	OutLine("После: ")
	PutTiersToTextFrame()
	PutParamsTiers()
	
	ClearDiagrArea() 
	DrawDiagrTiers()

	-- Оповещаем о конце работы))
	SoundPlay("pig.wav")
end

MainFunction()